#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
import tempfile
from pathlib import Path


def deploy(
    local_priv_key: Path,
    local_pub_key: Path,
    flake_uri: str,
    ssh_host: str,
    build_remote: bool,
):
    """
    Runs nixos-anywhere with specified parameters
    """
    with tempfile.TemporaryDirectory(prefix="deploy-secrets-") as tmpdir:
        tmp_path = Path(tmpdir)
        ssh_dir = tmp_path / "etc" / "ssh"
        ssh_dir.mkdir(parents=True, exist_ok=True)
        priv_key = ssh_dir / "ssh_host_ed25519_key"
        pub_key = ssh_dir / "ssh_host_ed25519_key.pub"
        priv_key.write_bytes(local_priv_key.read_bytes())
        pub_key.write_bytes(local_pub_key.read_bytes())

        os.chmod(tmp_path / "etc", 0o755)
        os.chmod(ssh_dir, 0o755)
        os.chmod(priv_key, 0o600)
        os.chmod(pub_key, 0o644)

        cmd = [
            "nix",
            "run",
            "github:nix-community/nixos-anywhere",
            "--",
            "--flake",
            f"{flake_uri}",
            "--extra-files",
            str(tmp_path),
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
    if os.geteuid() != 0:
        print("Script must be run as root")
        sys.exit(1)
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
        help="Path to flake. Defaults to root of this repo.",
        default=Path(__file__).parent.parent.resolve(),
    )
    parser.add_argument(
        "--pub",
        type=Path,
        help="Path to pubkey for new host. Defaults to /home/sam/.ssh/keys/{host}.pub",
    )
    parser.add_argument(
        "--priv",
        type=Path,
        help="Path to privkey for new host. Defaults to /home/sam/.ssh/keys/{host}",
    )
    parser.add_argument(
        "--target",
        "-T",
        type=str,
        help="Target SSH hostname - usually nixos@<ip>",
        required=True,
    )
    parser.add_argument("--remote", "-R", action="store_true", help="build on remote")
    args = parser.parse_args()
    if args.priv is None:
        args.priv = Path(f"/home/sam/.ssh/keys/{args.host}")
    if args.pub is None:
        args.pub = Path(f"/home/sam/.ssh/keys/{args.host}.pub")
    deploy(
        local_priv_key=args.priv,
        local_pub_key=args.pub,
        flake_uri=f"{args.flake}#{args.host}",
        ssh_host=args.target,
        build_remote=args.remote,
    )
