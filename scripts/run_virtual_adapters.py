import argparse
import docker
import time

IMAGE_CONFIGS = {
    "cnc": {
        "image_path": "ghcr.io/openfactorylabusine/virtual-cnc-adapter:latest",
        "name": "virtual-cnc-adapter",
        "ports": {'4842/tcp': 4842},
        "network": "openfactory-opcua_default"
    },
    "dusttrak": {
        "image_path": "ghcr.io/openfactorylabusine/virtual-dusttrak-adapter:latest",
        "name": "virtual-dusttrak-adapter",
        "ports": {'4841/tcp': 4841},
        "network": "openfactory-opcua_default"
    },
    "wtvb01": {
        "image_path": "ghcr.io/openfactorylabusine/virtual-wtvb01-adapter:latest",
        "name": "virtual-wtvb01-adapter",
        "ports": {'4844/tcp': 4844},
        "network": "openfactory-opcua_default"
    }
}

def parse_arguments():
    parser = argparse.ArgumentParser(description="Dynamically spin up OpenFactory virtual adapters.")
    parser.add_argument(
        'devices', 
        nargs='+', 
        help='List of device shorthand names to run (e.g., cnc, dusttrak, wtvb01)'
    )
    parser.add_argument(
        '--virtual',
        action='store_true',
        default=True,
        help='Pass virtual mode status to the adapter instances'
    )
    parser.add_argument(
        '--no-virtual',
        dest='virtual',
        action='store_false',
        help='Disable virtual mode and force adapters to look for real hardware devices'
    )
    return parser.parse_args()

def main():
    args = parse_arguments()
    client = docker.from_env()
    running_containers = []

    virtual_env_value = "true" if args.virtual else "false"

    try:
        for device in args.devices:
            if device not in IMAGE_CONFIGS:
                print(f"Error: Unknown device nickname '{device}'. Skipping. (Valid options: {list(IMAGE_CONFIGS.keys())})")
                continue
                
            config = IMAGE_CONFIGS[device]
            image_path = config["image_path"]
            container_name = config["name"]
            ports = config["ports"]
            network = config["network"]

            print(f"\nPulling {image_path}...")
            try:
                client.images.pull(image_path)
            except docker.errors.APIError as e:
                print(f"Error pulling image for {device}: {e}. Skipping.")
                continue

            try:
                old_container = client.containers.get(container_name)
                print(f"Found existing container '{container_name}'. Removing it...")
                old_container.stop()
                old_container.remove()
            except docker.errors.NotFound:
                pass

            print(f"Starting container '{container_name}' (Virtual: {virtual_env_value})...")
            
            container = client.containers.run(
                image_path,
                detach=True,
                name=container_name,
                ports=ports,
                network=network,
                environment={"VIRTUAL_DEVICE": virtual_env_value}
            )
            running_containers.append(container)
            print(f"Container {container.short_id} is running.")

        if not running_containers:
            print("\nNo containers were successfully started. Exiting.")
            return

        print("\nAll requested containers deployed. Press Ctrl+C to stop and remove them.")
        while True:
            time.sleep(1)

    except KeyboardInterrupt:
        print("\n[Ctrl+C detected] Initiating cleanup sequence...")
        for container in running_containers:
            try:
                print(f"Stopping and removing {container.name}...")
                container.stop()
                container.remove()
            except Exception as e:
                print(f"Error cleaning up {container.name}: {e}")
        print("Cleanup complete.")

if __name__ == "__main__":
    main()