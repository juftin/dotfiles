"""
Generate the code reference pages and navigation.
"""

import mkdocs_gen_files
from pathlib import Path

# Read the README.md content
readme_content = Path("README.md").read_text(encoding="utf-8")

# Replace relative links to docs/ with absolute links
readme_content = readme_content.replace("](docs/", "](")

# Split the content at each `<!--skip-->` and then join back only the non-skipped sections
sections = readme_content.split("<!--skip-->")
non_skipped_content = "".join(sections[i] for i in range(len(sections)) if i % 2 == 0)

# Write the non-skipped content to index.md
with mkdocs_gen_files.open("index.md", "w") as index_file:
    index_file.write(non_skipped_content)

# Read the bootstrap.sh content
bootstrap_content = Path("bootstrap/bootstrap.sh").read_bytes()
# Write the bootstrap.sh content to the output file
with mkdocs_gen_files.open("get", "wb") as bootstrap_file:
    bootstrap_file.write(bootstrap_content)
