import argparse
import os
import re
import subprocess
import tempfile
from pathlib import Path

from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap, CommentedSeq
from ruamel.yaml.scalarstring import PlainScalarString


def replace_references(node, old_value, new_value):
    if isinstance(node, CommentedMap):
        for key, value in node.items():
            if value is old_value:
                node[key] = new_value
            else:
                replace_references(value, old_value, new_value)
    elif isinstance(node, CommentedSeq):
        for idx, value in enumerate(node):
            if value is old_value:
                node[idx] = new_value
            else:
                replace_references(value, old_value, new_value)


def update_secrets(
    host_age_key: str,
    target_host: str,
    flake_path: Path,
    rule_index: int | None = None,
    auto_yes: bool = False,
):
    if not re.fullmatch(r"[A-Za-z0-9_-]+", target_host):
        raise ValueError(
            f"Invalid host name {target_host!r}: "
            "only alphanumeric characters, dash and underscore are allowed"
        )
    yaml_file = flake_path / ".sops.yaml"
    secrets_yaml = flake_path / "secrets.yaml"
    if not yaml_file.is_file():
        raise RuntimeError(f"SOPS config not found: {yaml_file}")
    if not secrets_yaml.is_file():
        raise RuntimeError(f"Encrypted secrets file not found: {secrets_yaml}")
    status = subprocess.run(
        ["git", "status", "--porcelain", "--", ".sops.yaml", "secrets.yaml"],
        cwd=flake_path,
        text=True,
        capture_output=True,
        check=True,
        timeout=120,
    )
    if status.stdout.strip():
        raise RuntimeError(
            "Flake has uncommitted changes to .sops.yaml/secrets.yaml; "
            "commit or stash them before deploying"
        )

    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.indent(mapping=2, sequence=4, offset=2)
    data = yaml.load(yaml_file.read_text())
    keys = data["keys"]

    found = False
    for key in keys:
        anchor = getattr(key, "anchor", None)
        anchor_name = anchor.value if anchor else None
        if anchor_name == target_host:
            if str(key) == host_age_key:
                print(f"Secrets key for {target_host} is unchanged")
                return
            replacement = PlainScalarString(host_age_key)
            replacement.yaml_set_anchor(target_host, always_dump=True)
            replace_references(data, key, replacement)
            found = True
            break
    if not found:
        replacement = PlainScalarString(host_age_key)
        replacement.yaml_set_anchor(target_host, always_dump=True)
        keys.append(replacement)

        creation_rules = data.get("creation_rules", [])
        if not creation_rules:
            raise RuntimeError(f"No creation_rules found in {yaml_file}")
        # Collect (rule_idx, key_group) pairs that contain an age list.
        indexed_age_groups: list[tuple[int, dict]] = [
            (rule_idx, key_group)
            for rule_idx, rule in enumerate(creation_rules)
            for key_group in rule.get("key_groups", [])
            if "age" in key_group
        ]
        if not indexed_age_groups:
            raise RuntimeError(f"No age key groups found in {yaml_file}")
        if rule_index is not None:
            if not 0 <= rule_index < len(creation_rules):
                raise ValueError(
                    f"--secrets-rule-index {rule_index} out of range "
                    f"(0..{len(creation_rules) - 1})"
                )
            target_groups = [
                group
                for idx, group in indexed_age_groups
                if idx == rule_index
            ]
            if not target_groups:
                raise RuntimeError(
                    f"creation_rules[{rule_index}] has no age key groups "
                    f"in {yaml_file}"
                )
        elif len(creation_rules) == 1 and len(indexed_age_groups) == 1:
            # Unambiguous: single rule with a single age group.
            target_groups = [indexed_age_groups[0][1]]
        else:
            # Ambiguous over-grant risk: don't silently add to every group.
            print(
                "Multiple creation rules / age key groups found; "
                "adding the new host key to all of them would over-grant "
                "access."
            )
            for idx, rule in enumerate(creation_rules):
                n_age = sum(
                    1 for kg in rule.get("key_groups", []) if "age" in kg
                )
                print(
                    f"  [{idx}] path_regex: "
                    f"{rule.get('path_regex', '<none>')} "
                    f"({n_age} age group(s))"
                )
            if auto_yes:
                raise RuntimeError(
                    "Refusing to choose a creation rule non-interactively: "
                    "re-run with an explicit --secrets-rule-index."
                )
            choice = input(
                "Enter the creation rule index to add the new host key to: "
            ).strip()
            try:
                chosen = int(choice)
            except ValueError:
                raise ValueError(
                    f"Invalid rule index {choice!r}: must be an integer"
                )
            if not 0 <= chosen < len(creation_rules):
                raise ValueError(
                    f"Rule index {chosen} out of range "
                    f"(0..{len(creation_rules) - 1})"
                )
            target_groups = [
                group
                for idx, group in indexed_age_groups
                if idx == chosen
            ]
            if not target_groups:
                raise RuntimeError(
                    f"creation_rules[{chosen}] has no age key groups "
                    f"in {yaml_file}"
                )
        for age_group in target_groups:
            age_group["age"].append(replacement)

        print(f"Added secrets key for {target_host}")
    # Atomic write: write to a temp file in the same directory, then replace.
    fd, tmp_name = tempfile.mkstemp(
        dir=str(flake_path), prefix=".sops.yaml.", suffix=".tmp"
    )
    try:
        with os.fdopen(fd, "w") as f:
            yaml.dump(data, f)
        os.replace(tmp_name, yaml_file)
    except BaseException:
        try:
            os.unlink(tmp_name)
        except OSError:
            pass
        raise

    subprocess.run(
        ["sops", "updatekeys", "-y", str(secrets_yaml)],
        cwd=flake_path,
        check=True,
        timeout=120,
    )

    # Secrets live in-tree, so commit them to the flake checkout. Pushing
    # is left to the user: `git push` also pushes unrelated commits.
    subprocess.run(
        ["git", "add", ".sops.yaml", "secrets.yaml"],
        cwd=flake_path,
        check=True,
        timeout=120,
    )
    subprocess.run(
        ["git", "commit", "-m", f"deploy: updated host {target_host}"],
        cwd=flake_path,
        check=True,
        timeout=120,
    )
    print("Committed updated secrets; run `git push` after deploying")


def get_age_key(host_ip: str, host_port: int) -> str:
    keyscan_cmd = [
        "ssh-keyscan",
        "-p",
        str(host_port),
        "-t",
        "ed25519",
        host_ip,
    ]
    keyscan = subprocess.run(
        keyscan_cmd,
        text=True,
        capture_output=True,
        check=True,
        timeout=30,
    )
    if not keyscan.stdout.strip():
        raise RuntimeError(
            f"ssh-keyscan returned no keys for {host_ip}:{host_port}"
        )

    # Show the TOFU key and its fingerprint so the user can verify it.
    print(f"ssh-keyscan result for {host_ip}:{host_port}:")
    print(keyscan.stdout.strip())
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".pub", delete=True
        ) as tf:
            tf.write(keyscan.stdout)
            tf.flush()
            fp = subprocess.run(
                ["ssh-keygen", "-lf", tf.name],
                text=True,
                capture_output=True,
                check=False,
                timeout=30,
            )
        if fp.stdout.strip():
            print(f"Key fingerprint(s):\n{fp.stdout.strip()}")
        else:
            print("WARNING: could not compute key fingerprint; raw key above.")
    except Exception as exc:  # noqa: BLE001 - fingerprint is best-effort
        print(f"WARNING: could not compute key fingerprint: {exc}")
    print(
        "WARNING: this host key is TOFU-unverified "
        "(trust-on-first-use). Verify the fingerprint out-of-band "
        "before proceeding, especially if you did not just reinstall "
        "this machine."
    )

    ssh_to_age = subprocess.run(
        ["ssh-to-age"],
        input=keyscan.stdout,
        text=True,
        capture_output=True,
        check=True,
        timeout=30,
    )
    keys = [
        line.strip()
        for line in ssh_to_age.stdout.splitlines()
        if line.strip().startswith("age1")
    ]
    if not keys:
        raise RuntimeError(f"No age key found for {host_ip}:{host_port}")
    return keys[0]


def clear_known_host_key(host_ip: str, host_port: int, auto_yes: bool = False):
    target = host_ip if host_port == 22 else f"[{host_ip}]:{host_port}"
    check = subprocess.run(
        ["ssh-keygen", "-F", target],
        text=True,
        capture_output=True,
        check=False,
        timeout=30,
    )
    old_entry = check.stdout.strip()
    if check.returncode != 0 or not old_entry:
        return
    print(f"WARNING: known_hosts already contains an entry for {target}:")
    print(old_entry)
    print(
        "The new host may legitimately have a different key (e.g. fresh "
        "install/reinstall), but a changed key can also indicate a "
        "man-in-the-middle attack. Do not remove the old entry unless "
        "you expected this change."
    )
    if not auto_yes:
        answer = input(
            f"Remove old known_hosts entry for {target}? [y/N]: "
        ).strip().lower()
        if answer not in ("y", "yes"):
            raise RuntimeError(
                f"Refusing to remove known_hosts entry for {target} "
                "without confirmation"
            )
    else:
        print(f"--yes given: removing old known_hosts entry for {target}")
    subprocess.run(
        ["ssh-keygen", "-R", target],
        text=True,
        capture_output=True,
        check=False,
        timeout=30,
    )


def deploy(
    flake_path: Path,
    flake_uri: str,
    ssh_host: str,
    ssh_port: int,
    build_remote: bool,
):
    """
    Runs nixos-anywhere with specified parameters
    """
    subprocess.run(
        ["nix", "flake", "archive", "--no-write-lock-file"],
        cwd=flake_path,
        check=True,
        timeout=120,
    )

    cmd = [
        "nix",
        "run",
        "github:nix-community/nixos-anywhere",
        "--",
        "--flake",
        f"{flake_uri}",
        "--copy-host-keys",
        "--target-host",
        ssh_host,
        "--ssh-option",
        # TOFU: accept and store a previously unseen host key, but still
        # reject a changed key for a known host. The candidate key was
        # fetched via ssh-keyscan and its fingerprint shown to the user
        # in get_age_key() above for out-of-band verification.
        "StrictHostKeyChecking=accept-new",
    ]
    if ssh_port != 22:
        cmd.extend(["--ssh-port", str(ssh_port)])
    if build_remote:
        cmd.extend(["--build-on", "remote"])

    print(f"Running: {' '.join(cmd)}\n")

    deploy_env = os.environ.copy()
    deploy_env.pop("SSH_AUTH_SOCK", None)
    subprocess.run(cmd, env=deploy_env, check=True, timeout=120)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Deploy a NixOS host with nixos-anywhere, rotating "
        "its sops age key into the in-tree secrets "
        "(.sops.yaml/secrets.yaml)."
    )
    parser.add_argument(
        "--host",
        "-H",
        type=str,
        help="Host to deploy. Must be a nixosConfiguration in flake",
        required=True,
    )
    parser.add_argument(
        "--flake",
        "-F",
        type=Path,
        help="Path to flake. Defaults to NH_FLAKE",
        default=Path(os.environ["NH_FLAKE"]).expanduser()
        if "NH_FLAKE" in os.environ
        else None,
    )
    parser.add_argument(
        "--target",
        "-T",
        type=str,
        help="Target SSH host in form <user>@<ip/hostname>",
        default="nixos@nixos",
    )
    parser.add_argument(
        "--port",
        "-p",
        type=int,
        help="Port to access ssh",
        default=22,
    )
    parser.add_argument(
        "--remote",
        "-R",
        action="store_true",
        help="build on remote",
    )
    parser.add_argument(
        "--yes",
        "-y",
        action="store_true",
        help="assume yes for interactive confirmations (non-interactive)",
    )
    parser.add_argument(
        "--secrets-rule-index",
        type=int,
        default=None,
        help="creation_rules index in .sops.yaml to add a new host key to",
    )
    args = parser.parse_args()
    if args.flake is None:
        parser.error("--flake is required when NH_FLAKE is not set")
    if args.target.count("@") != 1:
        parser.error("--target must be in the form <user>@<ip/hostname>")
    _, target_host = args.target.split("@", 1)
    if not target_host:
        parser.error("--target must be in the form <user>@<ip/hostname>")

    clear_known_host_key(
        host_ip=target_host, host_port=args.port, auto_yes=args.yes
    )

    age_key = get_age_key(host_ip=target_host, host_port=args.port)

    update_secrets(
        host_age_key=age_key,
        target_host=args.host,
        flake_path=args.flake,
        rule_index=args.secrets_rule_index,
        auto_yes=args.yes,
    )
    deploy(
        flake_path=args.flake,
        flake_uri=f"{args.flake}#{args.host}",
        ssh_host=args.target,
        ssh_port=args.port,
        build_remote=args.remote,
    )
