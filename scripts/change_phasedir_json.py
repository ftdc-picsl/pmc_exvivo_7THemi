import json
import sys

input_file = sys.argv[1]
output_file = sys.argv[2]
phase_dir = sys.argv[3]

with open(input_file, 'r') as f:
    data = json.load(f)

data["PhaseEncodingDirection"] = phase_dir

with open(output_file, 'w') as f:
    json.dump(data, f, indent=4)

print ("Phase encoding direction updated successfully!")
