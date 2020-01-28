export PATH=$PATH:/home/jb/.local/bin

export STEAM_COMPAT_DATA_PATH=$HOME/proton
export PROTON_HOME='/mnt/f1aa/data/SteamLibrary/steamapps/common/Proton 4.11/'
proton(){
	i=$(pwd)
	cd "$PROTON_HOME"
	pwd
	export PATH=$PATH:$(pwd)/dist/share/fonts/
	python3 ./proton $_
	cd $i
}

#16710 python3 /mnt/f1aa/data/SteamLibrary/steamapps/common/Proton 4.11/proton waitforexitandrun /mnt/f1aa/data/SteamLibrary/steamapps/common/Halo The Master Chief Collection/mcclauncher.exe
#16718 steam /mnt/f1aa/data/SteamLibrary/steamapps/common/Halo The Master Chief Collection/mcclauncher.exe                                                                                                                                                        
#16721 /mnt/f1aa/data/SteamLibrary/steamapps/common/Proton 4.11/dist/bin/wineserver
#16766 Z:\mnt\f1aa\data\SteamLibrary\steamapps\common\Halo The Master Chief Collection\MCC\Binaries\Win64\MCC-Win64-Shipping.exe -eac-nop-loaded  
