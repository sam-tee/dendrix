#!/usr/bin/env python3
import argparse
import os
import subprocess
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
    secret_dir: Path,
    flake_path: Path,
):
    yaml_file = secret_dir / ".sops.yaml"
    status = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=secret_dir,
        text=True,
        capture_output=True,
        check=True,
    )
    if status.stdout:
        raise RuntimeError(f"Secrets repository {secret_dir} has uncommitted changes")

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

        age_groups = [
            key_group["age"]
            for rule in data.get("creation_rules", [])
            for key_group in rule.get("key_groups", [])
            if "age" in key_group
        ]
        if not age_groups:
            raise RuntimeError(f"No age key groups found in {yaml_file}")
        for age_group in age_groups:
            age_group.append(replacement)

        print(f"Added secrets key for {target_host}")
    with yaml_file.open("w") as f:
        yaml.dump(data, f)

    subprocess.run(
        ["sops", "updatekeys", "-y", "secrets.yaml"],
        cwd=secret_dir,
        check=True,
    )

    subprocess.run(
        ["git", "commit", "-am", f"deploy: updated host {target_host}"],
        cwd=secret_dir,
        check=True,
    )
    subprocess.run(["git", "push"], cwd=secret_dir, check=True)
    subprocess.run(["nix", "flake", "update", "secrets"], cwd=flake_path, check=True)


def get_age_key(host_ip: str, host_port: int) -> str:
    keyscan_cmd = [
        "ssh-keyscan",
        "-t",
        "ed25519",
        "-p",
        str(host_port),
        host_ip,
    ]
    keyscan = subprocess.run(keyscan_cmd, text=True, capture_output=True, check=True)

    ssh_to_age = subprocess.run(
        ["ssh-to-age"],
        input=keyscan.stdout,
        text=True,
        capture_output=True,
        check=True,
    )
    keys = [
        line.strip()
        for line in ssh_to_age.stdout.splitlines()
        if line.strip().startswith("age1")
    ]
    if not keys:
        raise RuntimeError(f"No age key found for {host_ip}:{host_port}")
    return keys[0]


def deploy(
    flake_path: Path,
    flake_uri: str,
    ssh_host: str,
    build_remote: bool,
):
    """
    Runs nixos-anywhere with specified parameters
    """
    subprocess.run(
        ["nix", "flake", "archive", "--no-write-lock-file"],
        cwd=flake_path,
        check=True,
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
    ]
    if build_remote:
        cmd.append("--build-on-remote")

    print(f"Running: {' '.join(cmd)}\n")

    deploy_env = os.environ.copy()
    deploy_env.pop("SSH_AUTH_SOCK", None)
    subprocess.run(cmd, env=deploy_env, check=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
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
        "--secrets",
        "-S",
        type=Path,
        help="Path to secrets directory",
        default=Path("~/nix-secrets").expanduser(),
    )
    parser.add_argument(
        "--target",
        "-T",
        type=str,
        help="Target SSH host in form <user>@<ip/hostname>",
        required=True,
    )
    parser.add_argument("--port", "-p", type=int, help="Port to access ssh", default=22)
    parser.add_argument("--remote", "-R", action="store_true", help="build on remote")
    args = parser.parse_args()
    if args.flake is None:
        parser.error("--flake is required when NH_FLAKE is not set")
    try:
        _, target_host = args.target.rsplit("@", 1)
    except ValueError:
        parser.error("--target must be in the form <user>@<ip/hostname>")

    age_key = get_age_key(host_ip=target_host, host_port=args.port)
    update_secrets(
        host_age_key=age_key,
        target_host=args.host,
        secret_dir=args.secrets,
        flake_path=args.flake,
    )
    deploy(
        flake_path=args.flake,
        flake_uri=f"{args.flake}#{args.host}",
        ssh_host=args.target,
        build_remote=args.remote,
    )
