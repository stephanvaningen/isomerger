1) Zodra je /.../310-extract-redhat-to-relcan.sh uitvoert: komt hier een directory met als naam:
   - naam van de .iso + naam van de directory van de 'current' builds-and-bundles versie
   Bijvoorbeeld:
   	- je runt ./310* op het moment dat ./currents symbolic links wijzen naar /100../rhel-9.3-x86_64-boot.iso en /120../my-build3-v1.0
   	- dan komt er een folder met de naam /110../rhel-9.3-x86_64-boot-my-build3-v1.0 en daarin de inhoud van de RedHat-.iso
   	
2) Zodra je /.../320-merge-bab-into-relcan.sh uitvoert, wordt de eerder aangemaakte directory verder aangevuld met alle elementen van de build

3) En finally, als je /.../390-create-and-export-current-build.sh uitvoert, wordt van bovenstaande directory een .iso gemaakt en evt naar een USB geschreven op /dev/sdb

