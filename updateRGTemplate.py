import json
import os
import subprocess
import sys
from pprint import pprint

templateString = subprocess.check_output(['az.bat', 'group', 'export', '-n', 'bishal-packer-app', '-o', 'json']).decode(sys.stdout.encoding)
template = json.loads(templateString)

print(template["resources"])

template["parameters"]["imageUrl"] = {
                                        "defaultValue": "",
                                        "type": "String"
                                     }

for resource in template["resources"]:
       if resource["type"] == "Microsoft.Compute/virtualMachineScaleSets": 
           resource["properties"]["virtualMachineProfile"]["storageProfile"]["osDisk"]["image"] = "[parameters('imageUrl')]"
           #pprint(resource)

pprint(template["resources"])

#outputFile = os.path.join($(System.DefaultWorkingDirectory), "updatedResourceTemplate.json")
outputFile = os.path.join("E:\\github\\packer-sample", "updatedResourceTemplate.json")
with open(outputFile, 'w') as f:
     json.dump(template, f)


