use v6.c;

use GLib::Object::Type;

use GIO::TypeManifest;

INIT {
  REGISTER-GOBJECT-TYPES( GIO::TypeManifest.manifest )
}
