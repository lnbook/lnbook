from __future__ import print_function
import glob
import re

markup_files = glob.glob('*.asciidoc')
anchor_re = re.compile("\[\[(.*)\]\]")
ref_re = re.compile(".*\<\<([^\>]*)\>\>.")

refs = {}
anchors = {}
dup_anchors = {}


# Find anchors and references in asciidoc files

for markup_file in markup_files:
	markup_f = open(markup_file, 'r')
	markup_contents = markup_f.read()
	markup_f.close()
	for linenum,line in enumerate(markup_contents.splitlines()):
		ref_match = ref_re.match(line)
		if ref_match:
			if ref_match.group(1) not in refs.keys():
				refs[ref_match.group(1)] = {
					'ref'	:	ref_match.group(1),
					'file'	:	markup_file,
					'linenum' : linenum,
					'line' : line,
				}
		anchor_match = anchor_re.match(line)
		if anchor_match:
			if anchor_match.group(1) not in anchors.keys():
				anchors[anchor_match.group(1)] = {
					'ref'	:	anchor_match.group(1),
					'file'	:	markup_file,
					'linenum' : linenum,
					'line' : line,
				}
			else:
				dup_anchors[anchor_match.group(1)] = {
					'ref'	:	anchor_match.group(1),
					'file'	:	markup_file,
					'linenum' : linenum,
					'line' : line,
				}


# Find broken, unmatched, missing
broken_refs = set(refs.keys()) - set(anchors.keys())
missing_refs = set(anchors.keys()) -  set(refs.keys())

print("\nAnchors: ", len(anchors), "\n")
print('\n'.join(sorted(anchors.keys())))
# print("\nDuplicated Anchors: ", len(dup_anchors))
# print('\n'.join(sorted(dup_anchors.keys())))
# print("\nReferences: ", len(refs), "\n")
# print('\n'.join(sorted(refs.keys())))



print("\nBroken Reference Detail: ")

for br in sorted(broken_refs):
	print(f"{refs[br]['ref']} : {refs[br]['file']}:{refs[br]['linenum']}")
