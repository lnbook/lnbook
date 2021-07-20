#!/usr/bin/env python
# coding: utf-8

from __future__ import print_function
import glob
import re
import requests
from pprint import pprint as p

# Location of raw BOLT #4 document
BOLT4 = "https://raw.githubusercontent.com/lightningnetwork/lightning-rfc/master/04-onion-routing.md"


# Get the text of BOLT #4
bolt4_get = requests.get(BOLT4)
bolt4_get.raise_for_status()

# Prepare regular expression to extract failure codes

# Regex: Extract the section
failure_type_section_re = re.compile("^The following .failure_code.s are defined.\n([^#]*)\n^### Requirements", flags=re.MULTILINE)

# Regex: Parse into separate fields
failure_type_re = re.compile("^1\.\stype:\s(?P<type_code>\S+)\s\(`(?P<type_name>\S+)`\)\s*(2\.\sdata:\s*(?P<data_section>(\s*\*\s*.*)*))?\n+(?P<description>[^\.:]*)", flags=re.MULTILINE)

# Extract the failure type section from BOLT #4
failure_type_section = failure_type_section_re.search(bolt4_get.text).group(1)

# Extract the fields of each failure type
failure_types = failure_type_re.finditer(failure_type_section)

# Open the file for the asciidoc table
failure_types_table = open("failure_types_table.asciidoc", "wt")

# Write table header
failure_types_table.write("|===\n")
failure_types_table.write("| type | symbolic name | meaning\n")

# Iterate over failure types extracted from BOLT
for f in failure_types:

	# Convert each match into a dictionary
    f = f.groupdict()

	# Escape "|" character because it is used as table column separator in asciidoc
    f["type_code"] = re.sub(r'\|','\|', f["type_code"])

	# Write each failure type in the table
	failure_types_table.write(f'| {f["type_code"]} | {f["type_name"]} | {f["description"]}\n')

# Write table footer
failure_types_table.write("|===")
failure_types_table.close()
