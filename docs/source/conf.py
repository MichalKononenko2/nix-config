# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

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
  "sphinx_design",
  "myst_parser"
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
