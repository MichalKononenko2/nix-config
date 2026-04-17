# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

from urllib.parse import urlsplit
from sphinx.util import logging

logger = logging.getLogger(__name__)

project = 'Nix-Config'
copyright = '2026, Michal Kononenko'
author = 'Michal Kononenko'
release = '0.1'

source_repository = 'https://github.com/MichalKononenko2/nix-config'

language = "en"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
  "sphinxcontrib_nixdomain",
  "sphinx.ext.githubpages",
  "sphinx.ext.intersphinx",
  "myst_parser",
  "sphinx_design"
]

myst_enable_extensions = ["colon_fence", "fieldlist"]

templates_path = ['_templates']
exclude_patterns = []

intersphinx_mapping = {
  'nixdomain': ('https://sphinxcontrib-nixdomain.readthedocs.io/en/latest', None)
}


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'classic'
html_static_path = ['_static']

def nixdomain_linkcode_resolve(path: str) -> str:
  url = urlsplit(path)
  fragment = "#" + url.fragment if url.fragment else ""

  match url.netloc:
    case "self":
      return f"https://example.com/blob/master{url.path}{fragment}"
    case "nixpkgs":
      return f"https://github.com/NixOS/nixpkgs/blob/master{url.path}{fragment}"
    case _:
      logger.warning("no source repository for url: %s", path)
      return ""

