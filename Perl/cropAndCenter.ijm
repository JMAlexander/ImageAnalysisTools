path="~/Desktop/Test_Folder";
call("ij.io.OpenDialog.setDefaultDirectory", path);
selectWindow("042516_092915_2E5_CymRHaloJF646_TetRtdtagRFP-T_4_Denoised_merged-1.tif");
xvalues=newArray(283, 279, 266, 264, 266, 274, 274, 276, 279, 280, 280, 278, 274, 274, 275, 280, 282, 282, 290, 290);
yvalues=newArray(190, 191, 190, 192, 189, 189, 193, 193, 189, 192, 195, 196, 195, 196, 199, 201, 204, 197, 204, 204);
getDimensions(width,height,channels,slices,frames);
for (i=0; i<=19; i++){
selectWindow("042516_092915_2E5_CymRHaloJF646_TetRtdtagRFP-T_4_Denoised_merged-1.tif");
current_slice=(i+1);	
setSlice(current_slice);
makeRectangle(round(xvalues[i]-16), round(yvalues[i]-16),32,32);
file_name="042516_092915_2E5_CymRHaloJF646_TetRtdtagRFP-T_t" + current_slice;
run("Duplicate...", "title=&file_name");
print(file_name);
output_file="/Users/Jeff/Desktop/Test_Folder/"+file_name;
saveAs("Tiff", output_file);
selectWindow(file_name + ".tif");
run("Close");
}
