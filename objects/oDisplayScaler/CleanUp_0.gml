/// @description Free Camera

// Duplicates destroy themselves before creating a camera
if (variable_instance_exists(id, "camera_")) {
	camera_destroy(camera_);
}
