#!/usr/bin/env python3

import errno
import os
import pathlib


config_dir = os.path.join(os.path.expanduser("~"), ".config")

# https://gist.github.com/gagarine/cf3f65f9be6aa0e105b184376f765262
def chsh():
	pass

def create_symlink(source, destination):
    try:
        os.symlink(source, destination)
        print(f"Created symlink: {destination} -> {source}")
    except OSError as e:
        if e.errno == errno.EEXIST:
            print(f"Symlink already exists: {destination} -> {source}")
        else:
            raise

def config_path(directory):
    return os.path.join(config_dir, directory)

def dotfile_path(directory):
    return os.path.join(pathlib.Path(__file__).parent.resolve(), directory)

def main():
    if not os.path.exists(config_dir):
        print(f"{config_dir} does not exist. Making it now.")
        os.makedirs(config_dir)

    # Define a list of configurations and their corresponding destination paths
    configurations = [
        {
            "source": dotfile_path("nvim"),
            "destination": config_path("nvim"),
        },
        {
            "source": dotfile_path("fish"),
            "destination": config_path("fish"),
        },
        {
            "source": dotfile_path("k9s"),
            "destination": config_path("k9s"),
        },
    ]

    for config in configurations:
        create_symlink(config["source"], config["destination"])

if __name__ == "__main__":
    main()

