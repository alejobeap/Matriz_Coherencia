import volcdb

frame = "142D_09148_131313"
volcanoes = volcdb.get_volcanoes_in_frame(frame)

index_to_find = 2229  # dataframe index (not volc_id)

if index_to_find in volcanoes.index:
    volcano_name = volcanoes.loc[index_to_find, 'name']
    print(f"Volcano name at index {index_to_find} is: {volcano_name}")
else:
    print(f"No volcano found with index {index_to_find}")
