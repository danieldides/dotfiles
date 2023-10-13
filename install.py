#!/usr/bin/env python3

import os


home_dir = os.path.expanduser("~")

def create_symlink(source, destination):
    try:
        os.symlink(source, destination)
        print(f"Created symlink: {destination} -> {source}")
    except OSError as e:
        if e.errno == os.errno.EEXIST:
            print(f"Symlink already exists: {destination} -> {source}")
        else:
            raise

def main():
    # Define a list of configurations and their corresponding destination paths

    # config_path = os.path.join(home_dir, ".config", "your_application_name")

    configurations = [
        {
            "source": "/path/to/git/repo/config1",
            "destination": "/path/to/destination1/config1"
        },
        {
            "source": "/path/to/git/repo/config2",
            "destination": "/path/to/destination2/config2"
        },
        # Add more configurations as needed
    ]

    for config in configurations:
        create_symlink(config["source"], config["destination"])

if __name__ == "__main__":
    main()

