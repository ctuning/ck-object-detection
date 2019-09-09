This package contains an example of a "custom model" for the object-detection-tf-py application.

as explained in the application (in the ck-tensorflow repository), there are some hooks inserted into the application that allow anyone to integrate a model that is not structured as the models in the tensorflow zoo into the application.
these hooks are contained in the two files present in this package(`custom_hooks.py` and `custom_tensorRT.py`)
The interface of these functions MUST be as follows:
`custom_hooks.py` has to expose five functions:
`ck_custom_preprocess`
`ck_custom_get_tensors`
`ck_custom_postprocess`
`ck_custom_preprocess_batch`
`ck_custom_postprocess_batch`


More in detail, the function descriptions and parameters have to follow the following scheme.

-`ck_custom_preprocess` and `ck_custom_preprocess_batch`:
in charge or preparing the image for the detection. must produce the input tensor and some other helper data.
	in:
		image_files          -> list with all the filenames of the image to process, with full path
		iter_num             -> integer with the loop iteration value
		processed_image_ids  -> list with the ids of all the processed images, it's an in-out parameter (the function must append to this)
		params               -> dictionary with the application parameters
	out:
		image_data           -> numpy array to be fed to the detection graph (input tensor)
		processed_image_ids  -> see input parameters
		image_size           -> [list of] tuple with the sizes. depends if batch is used or not, if not is a single tuple
		original_image       -> [list of] list containing the original images as read before the modification done in preprocessing. may be useless

-`ck_custom_postprocess` and `ck_custom_postprocess_batch`:
in charge of producing the output of the detection. must read output tensors and produce the txt file with the detections, and if required the images with the boxes.
	in:
		image_files	     -> list with all the filenames of the image to process, with full path
		iter_num             -> integer with the loop iteration value
		image_size	     -> [list of] tuple with the sizes. depends if batch is used or not, if not is a single tuple
		original_image       -> [list of] list containing the original images as read before the modification done in preprocessing. may be useless
		image_data           -> numpy array to be fed to the detection graph (input tensor)
		output_dict          -> output tensors. dictionary containing the tensors as "name : value" couples.
		category_index       -> dictionary to identify label and categories
		params               -> dictionary with the application parameters
	out:
		------

-`ck_custom_get_tensors`:
in charge of getting the input and output tensors from the model graph.
	in: 
		------
	out:
		tensor_dict          -> dictionary with the output tensors
		input_tensor         -> input tensor



The batch processing functions have the same interface of the functions that work without batch, the main difference between them is in the structure of the input/output in the single image processing, the input array has to be (for example) [1, H, W, C], while for the batch is [N, H, W, C].
In the same way, the postprocessing function will receive the output array from the network according to the network shape and the difference will be in the first dimension. 


The second file, `custom_tensorRT.py`, contains the functions required to support the tensorRT backend. These functions are:

`load_graph_tensorrt_custom`
`convert_from_tensorrt`     
`get_handles_to_tensors_RT` 

More in detail, function must support the interfaces as follows:

-`load_graph_tensorrt_custom`
in charge of loading the graph from a frozen model.
	in:
		params               -> dictionary with the application parameters
	
	out:
		------

-`convert_from_tensorrt`:
in charge of converting the dictionary if tensorRT is used, since output in tensorRT is a list and not a dict
	in:
		output_dict          -> output tensors. if tensorRT, is a list containing the output tensors 

	out:
		output_dict          -> output tensors. dictionary containing the tensors as "name : value" couples.


-`get_handles_to_tensors_RT`:
in charge of getting the input and output tensors from the model graph.
	in: 
		------
	out:
		tensor_dict          -> dictionary with the output tensors
		input_tensor         -> input tensor



The internal tensor representation is strictly linked to the model, and the application is completely agnostic in this aspect. The programmer is in charge to keep the coherency between the preprocess, get tensor and postprocess functions.
