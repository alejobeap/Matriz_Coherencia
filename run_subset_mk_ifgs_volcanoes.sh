#!/bin/bash

parent_dir=$(basename "$(dirname "$(pwd)")")
current_dir=$(basename "$(pwd)")

chmod 777 subset_mk_ifgs_volcanoes.sh 
./subset_mk_ifgs_volcanoes.sh -P $LiCSAR_procdir/subsets/${parent_dir}/${current_dir} ${pwd}/IFSforLiCSBAS.txt
