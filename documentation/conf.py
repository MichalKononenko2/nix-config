"""
Configuration for my nix config Sphinx docs.
"""

project = "nix-config"
author = "Michal Kononenko"
extensions = [
    "sphinxcontrib_nixdomain"
]
html_theme = "classic"
exclude_patterns = ["_build"]

