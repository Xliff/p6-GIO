use v6.c;

use GLib::Raw::Enums;
use GIO::Raw::Icon;

unit package GIO::Raw::FileAttributeTypes;

our enum GFileAttributes is export (
  G_FILE_ATTRIBUTE_STANDARD_TYPE                      => [ 'standard::type',                        G_TYPE_UINT       ], # GFileType
  G_FILE_ATTRIBUTE_STANDARD_IS_HIDDEN                 => [ 'standard::is-hidden',                   G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_STANDARD_IS_BACKUP                 => [ 'standard::is-backup',                   G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_STANDARD_IS_SYMLINK                => [ 'standard::is-symlink',                  G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_STANDARD_IS_VIRTUAL                => [ 'standard::is-virtual',                  G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_STANDARD_IS_VOLATILE               => [ 'standard::is-volatile',                 G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_STANDARD_NAME                      => [ 'standard::name',                        G_TYPE_POINTER    ],
  G_FILE_ATTRIBUTE_STANDARD_DISPLAY_NAME              => [ 'standard::display-name',                G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_STANDARD_EDIT_NAME                 => [ 'standard::edit-name',                   G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_STANDARD_COPY_NAME                 => [ 'standard::copy-name',                   G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_STANDARD_DESCRIPTION               => [ 'standard::description',                 G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_STANDARD_ICON                      => [ 'standard::icon',                        G_TYPE_OBJECT     ], # GIcon
  G_FILE_ATTRIBUTE_STANDARD_SYMBOLIC_ICON             => [ 'standard::symbolic-icon',               G_TYPE_OBJECT     ], # GIcon
  G_FILE_ATTRIBUTE_STANDARD_CONTENT_TYPE              => [ 'standard::content-type',                G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_STANDARD_FAST_CONTENT_TYPE         => [ 'standard::fast-content-type',           G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_STANDARD_SIZE                      => [ 'standard::size',                        G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_STANDARD_ALLOCATED_SIZE            => [ 'standard::allocated-size',              G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_STANDARD_SYMLINK_TARGET            => [ 'standard::symlink-target',              G_TYPE_POINTER    ],
  G_FILE_ATTRIBUTE_STANDARD_TARGET_URI                => [ 'standard::target-uri',                  G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_STANDARD_SORT_ORDER                => [ 'standard::sort-order',                  G_TYPE_INT        ],
  G_FILE_ATTRIBUTE_ETAG_VALUE                         => [ 'etag::value',                           G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_ID_FILE                            => [ 'id::file',                              G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_ID_FILESYSTEM                      => [ 'id::filesystem',                        G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_ACCESS_CAN_READ                    => [ 'access::can-read',                      G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_ACCESS_CAN_WRITE                   => [ 'access::can-write',                     G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_ACCESS_CAN_EXECUTE                 => [ 'access::can-execute',                   G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_ACCESS_CAN_DELETE                  => [ 'access::can-delete',                    G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_ACCESS_CAN_TRASH                   => [ 'access::can-trash',                     G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_ACCESS_CAN_RENAME                  => [ 'access::can-rename',                    G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_MOUNTABLE_CAN_MOUNT                => [ 'mountable::can-mount',                  G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_MOUNTABLE_CAN_UNMOUNT              => [ 'mountable::can-unmount',                G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_MOUNTABLE_CAN_EJECT                => [ 'mountable::can-eject',                  G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_MOUNTABLE_UNIX_DEVICE              => [ 'mountable::unix-device',                G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_MOUNTABLE_UNIX_DEVICE_FILE         => [ 'mountable::unix-device-file',           G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_MOUNTABLE_HAL_UDI                  => [ 'mountable::hal-udi',                    G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_MOUNTABLE_CAN_START                => [ 'mountable::can-start',                  G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_MOUNTABLE_CAN_START_DEGRADED       => [ 'mountable::can-start-degraded',         G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_MOUNTABLE_CAN_STOP                 => [ 'mountable::can-stop',                   G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_MOUNTABLE_START_STOP_TYPE          => [ 'mountable::start-stop-type',            G_TYPE_UINT       ], # (GDriveStart S, topType)
  G_FILE_ATTRIBUTE_MOUNTABLE_CAN_POLL                 => [ 'mountable::can-poll',                   G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_DOS_IS_ARCHIVE                     => [ 'dos::is-archive',                       G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_MOUNTABLE_IS_MEDIA_CHECK_AUTOMATIC => [ 'mountable::is-media-check-automatic',   G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_TIME_MODIFIED                      => [ 'time::modified',                        G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_TIME_MODIFIED_USEC                 => [ 'time::modified-usec',                   G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_TIME_ACCESS                        => [ 'time::access',                          G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_TIME_ACCESS_USEC                   => [ 'time::access-usec',                     G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_TIME_CHANGED                       => [ 'time::changed',                         G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_TIME_CHANGED_USEC                  => [ 'time::changed-usec',                    G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_TIME_CREATED                       => [ 'time::created',                         G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_TIME_CREATED_USEC                  => [ 'time::created-usec',                    G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_UNIX_DEVICE                        => [ 'unix::device',                          G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_UNIX_INODE                         => [ 'unix::inode',                           G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_UNIX_MODE                          => [ 'unix::mode',                            G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_UNIX_NLINK                         => [ 'unix::nlink',                           G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_UNIX_UID                           => [ 'unix::uid',                             G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_UNIX_GID                           => [ 'unix::gid',                             G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_UNIX_RDEV                          => [ 'unix::rdev',                            G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_UNIX_BLOCK_SIZE                    => [ 'unix::block-size',                      G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_UNIX_BLOCKS                        => [ 'unix::blocks',                          G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_UNIX_IS_MOUNTPOINT                 => [ 'unix::is-mountpoint',                   G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_DOS_IS_SYSTEM                      => [ 'dos::is-system',                        G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_DOS_IS_MOUNTPOINT                  => [ 'dos::is-mountpoint',                    G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_DOS_REPARSE_POINT_TAG              => [ 'dos::reparse-point-tag',                G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_OWNER_USER                         => [ 'owner::user',                           G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_OWNER_USER_REAL                    => [ 'owner::user-real',                      G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_OWNER_GROUP                        => [ 'owner::group',                          G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_THUMBNAIL_PATH                     => [ 'thumbnail::path',                       G_TYPE_POINTER    ],  # Bytestring
  G_FILE_ATTRIBUTE_THUMBNAILING_FAILED                => [ 'thumbnail::failed',                     G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_THUMBNAIL_IS_VALID                 => [ 'thumbnail::is-valid',                   G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_PREVIEW_ICON                       => [ 'preview::icon',                         g_icon_get_type() ],
  G_FILE_ATTRIBUTE_FILESYSTEM_SIZE                    => [ 'filesystem::size',                      G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_FILESYSTEM_FREE                    => [ 'filesystem::free',                      G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_FILESYSTEM_USED                    => [ 'filesystem::used',                      G_TYPE_UINT64     ],
  G_FILE_ATTRIBUTE_FILESYSTEM_TYPE                    => [ 'filesystem::type',                      G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_FILESYSTEM_READONLY                => [ 'filesystem::readonly',                  G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_FILESYSTEM_USE_PREVIEW             => [ 'filesystem::use-preview',               G_TYPE_UINT       ], # GFilesystem PreviewType)
  G_FILE_ATTRIBUTE_FILESYSTEM_REMOTE                  => [ 'filesystem::remote',                    G_TYPE_BOOLEAN    ],
  G_FILE_ATTRIBUTE_GVFS_BACKEND                       => [ 'gvfs::backend',                         G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_SELINUX_CONTEXT                    => [ 'selinux::context',                      G_TYPE_STRING     ],
  G_FILE_ATTRIBUTE_TRASH_ITEM_COUNT                   => [ 'trash::item-count',                     G_TYPE_UINT       ],
  G_FILE_ATTRIBUTE_TRASH_ORIG_PATH                    => [ 'trash::orig-path',                      G_TYPE_POINTER    ], # Bytestring
  G_FILE_ATTRIBUTE_RECENT_MODIFIED                    => [ 'recent::modified',                      G_TYPE_INT64      ], # time_t
  G_FILE_ATTRIBUTE_TRASH_DELETION_DATE                => [ 'trash::deletion-date',                  G_TYPE_STRING     ]
);

my %FileAttributeTypes;

BEGIN { %FileAttributeTypes = GFileAttributes.enums.map({ .value[0] => .value[1] }).Hash }

sub GFileAttributeName        ($a) is export { $a.value[0] }
sub GFileAttributeType        ($a) is export { $a.value[1] }

sub fAttrVal ($a)  is export { $a.value[0] }
sub fAttrType ($a) is export { $a.value[1] }

sub getFileAtributeTypeByName ($n) is export { %FileAttributeTypes{$n} }
