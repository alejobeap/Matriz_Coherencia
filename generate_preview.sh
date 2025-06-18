#!/bin/bash

# Function to create the color bar for unwrapped data
create_colourbar_unw() {
    infile=$1
    echo "Debug: Starting color bar creation for $infile"

    if [ ! -f "$infile" ]; then
        echo "Error: Input file $infile does not exist."
        exit 1
    fi

    scalebarfile=$(dirname $infile)/scalebar_unwrapped.png
    minmaxcolour=$(gmt grdinfo -T+a1+s "$infile")
    if [ $? -ne 0 ]; then
        echo "Error: gmt grdinfo failed on $infile"
        exit 1
    fi

    mincol=$(echo $minmaxcolour | cut -d '/' -f1 | cut -d 'T' -f2)
    maxcol=$(echo $minmaxcolour | cut -d '/' -f2)
    minval=$(python -c "print(round($mincol * 5.546 / (4 * 3.14159265)))")
    maxval=$(python -c "print(round($maxcol * 5.546 / (4 * 3.14159265)))")

    minmaxreal=$(gmt grdinfo -T "$infile")
    minreal=$(echo $minmaxreal | cut -d 'T' -f2 | cut -d '/' -f1 | cut -d '.' -f1)
    maxreal=$(echo $minmaxreal | cut -d '/' -f2 | cut -d '.' -f1)
    minrealval=$(python -c "print(round($minreal * 5.546 / (4 * 3.14159265)))")
    maxrealval=$(python -c "print(round($maxreal * 5.546 / (4 * 3.14159265)))")

    xsize=80
    if [ ${#minval} -gt 3 ]; then xsize=$((80 - (${#minval} - 3) * 20)); fi

    convert -font helvetica -fill black -pointsize 40 \
        -draw "text $xsize,115 '$minval'" \
        "$LiCSARpath/misc/scalebar_unwrapped_empty.png" "$infile.temp_scale_unw.png"

    convert -font helvetica -fill black -pointsize 40 \
        -draw "text 1100,115 '$maxval cm'" \
        "$infile.temp_scale_unw.png" "$infile.scalebar_unwrapped.png"

    mv "$infile.scalebar_unwrapped.png" "$infile.temp_scale_unw.png"

    convert -font helvetica -fill black -pointsize 35 \
        -draw "text $xsize,165 '[min $minrealval cm]'" \
        "$infile.temp_scale_unw.png" "$infile.scalebar_unwrapped.png"

    mv "$infile.scalebar_unwrapped.png" "$infile.temp_scale_unw.png"

    convert -font helvetica -fill black -pointsize 35 \
        -draw "text 1020,165 '[max $maxrealval cm]'" \
        "$infile.temp_scale_unw.png" "$scalebarfile"

    rm "$infile.temp_scale_unw.png"

    echo "$scalebarfile"
}

# Function to create a preview for unwrapped data
create_preview_unwrapped() {
    if [ ! -z "$1" ]; then
        local unwfile=$1
        echo "Generating preview for: $unwfile"

        origfile=$unwfile
        outfile=$(echo $unwfile | rev | cut -c 4- | rev)png
        unwfile=$origfile.tmp.tif

        gmt grdclip $origfile -G$unwfile.nc -Sr0/NaN
        gmt grdmath $unwfile.nc $unwfile.nc MEDIAN SUB = $unwfile=gd:Gtiff
        rm $unwfile.nc

        extracmd=''
        if [ ! -z "$2" ]; then
            frame=$2
            maskedfile=$(prepare_landmask $unwfile $frame)
            if [ ! -z $maskedfile ]; then
                unwfile=$maskedfile
            fi
        fi

        barpng=$(create_colourbar_unw $unwfile)
        if [ $? -ne 0 ]; then
            echo "Error: Color bar generation failed."
            exit 1
        fi

        minmaxcolour=$(gmt grdinfo -T+a1+s $unwfile)
        gmt makecpt -C$LiCSARpath/misc/colourmap.cpt -Iz $minmaxcolour/0.025 >$outfile.unw.cpt

        if [ -z "$3" ]; then
            gmt grdimage $unwfile -C$outfile.unw.cpt $extracmd -JM1 -Q -nn+t0.1 -A$outfile.tt.png
            convert $outfile.tt.png PNG8:$outfile
            rm $outfile.tt.png

            grav='southwest'
            convert $outfile -resize 680x \( $barpng -resize 400x -background none -gravity center \) \
                -gravity $grav -geometry +7+7 -composite -flatten -transparent black $outfile

            mv $outfile.sm.png $outfile
            rm $barpng $outfile.unw.cpt
        fi
    else
        echo "Usage: create_preview_unwrapped unwrapped_ifg [frame] [to kmz?]"
        return 0
    fi
}

# Run the script with input parameters
create_preview_unwrapped "$@"
