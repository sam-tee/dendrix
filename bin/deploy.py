#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
from pathlib import Path

from ruamel.yaml import YAML
from ruamel.yaml.scalarstring import PlainScalarString


def update_secrets(
    host_age_key: str,
    target_host: str,
    secret_dir: Path,
    flake_path: Path,
):
    yaml_file = secret_dir / ".sops.yaml"
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.indent(mapping=2, sequence=4, offset=2)
    data = yaml.load(yaml_file.read_text())
    keys = data["keys"]

    found = False
    for idx, key in enumerate(keys):
        anchor = getattr(key, "anchor", None)
        anchor_name = anchor.value if anchor else None
        if anchor_name == target_host:
            replacement = PlainScalarString(host_age_key)
            replacement.yaml_set_anchor(target_host, always_dump=True)
            keys[idx] = replacement
            found = True
            break
    if not found:
        sys.exit(1)
    with yaml_file.open("w") as f:
        yaml.dump(data, f)

    subprocess.run(["nix", "flake", "update", "secrets"], cwd=flake_path)

    subprocess.run(
        ["git", "commit", "-am", f"deploy: updated host {target_host}"], cwd=secret_dir
    )
    subprocess.run(["git", "push"], cwd=secret_dir)


def get_age_key(host_ip: str, host_port: int) -> str:
    keyscan_cmd = [
        "ssh-keyscan",
        "-t",
        "ed25519",
        "-P",
        str(host_port),
        host_ip,
    ]
    keyscan = subprocess.run(keyscan_cmd, text=True, check=False)

    ssh_to_age = subprocess.run(
        ["ssh-to-age"], input=keyscan.stdout, text=True, check=False
    )
    keys = [
        line.strip()
        for line in ssh_to_age.stdout.splitlines()
        if line.strip().startswith("age1")
    ]
    return keys[0]


def deploy(
    flake_uri: str,
    ssh_host: str,
    build_remote: bool,
):
    """
    Runs nixos-anywhere with specified parameters
    """
    cmd = [
        "sudo",
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
        cmd.extend("--build-on-remote")

    print(f"Running: {' '.join(cmd)}\n")

    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(e)


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
        default=os.getenv("NH_FLAKE"),
    )
    parser.add_argument(
        "--secrets",
        "-S",
        type=Path,
        help="Path to secrets directory",
        default=Path("~/nix-secrets").resolve(),
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
    ip, user = args.target.split("@")
    age_key = get_age_key(host_ip=ip, host_port=args.port)
    update_secrets(
        host_age_key=age_key,
        target_host=args.host,
        secret_dir=args.secrets,
        flake_path=args.flake,
    )
    deploy(
        flake_uri=f"{args.flake}#{args.host}",
        ssh_host=args.target,
        build_remote=args.remote,
    )
