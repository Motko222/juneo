#!/bin/bash

cd ~
rm -r juneogo-binaries
git clone https://github.com/Juneo-io/juneogo-binaries
chmod +x ~/juneogo-binaries/juneogo
chmod +x ~/juneogo-binaries/plugins/jevm
chmod +x ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e
mkdir -p ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/jevm ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e ~/.juneogo/plugins
mkdir ~/juneogo
cp ~/juneogo-binaries/juneogo ~/juneogo
