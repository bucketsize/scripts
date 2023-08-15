#STEAM_COMPAT_DATA_PATH=/mnt/f1aa/data/SteamLibrary/steamapps/compatdata/976730 \
#	/mnt/f1aa/data/SteamLibrary/steamapps/common/Proton\ 5.0/proton \
#	waitforexitandrun \
#	/mnt/f1aa/data/SteamLibrary/steamapps/common/Planet\ Zoo/PlanetZoo.exe

pdc=$pwd
export STEAM_COMPAT_DATA_PATH=$HOME/proton
cd /mnt/f1aa/data/SteamLibrary/steamapps/common/Proton\ 5.0/
./proton waitforexitandrun $1
cd $pdc
