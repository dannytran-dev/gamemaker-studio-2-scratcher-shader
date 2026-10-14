/// @description Free Mask + Particles

if (surface_exists(maskSurface_)) surface_free(maskSurface_);
if (buffer_exists(maskBuffer_)) buffer_delete(maskBuffer_);

part_type_destroy(flakeType_);
part_system_destroy(flakeSystem_);
