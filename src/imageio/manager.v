module imageio

import sync
import runtime
import math

pub enum LoadStatus {
	loading
	loaded
	failed
}

pub const supported_ldr_file_types = ['png', 'jpg', 'jpeg', 'bmp', 'tga', 'gif', 'psd', 'hdr',
	'pic', 'pnm', 'ppm', 'pgm', 'pbm', 'pam', 'tga', 'tiff', 'tif', 'exr', 'webp', 'jxr', 'jxl',
	'bpg', 'brd', 'ico', 'cur', 'dds', 'dng', 'heif', 'heic', 'avif', 'flif', 'jng', 'jbig', 'jbig2',
	'jp2', 'jpm', 'jpx', 'jxr']

pub const supported_raw_file_types_str = ['nef', 'cr2', 'cr3', 'raf', 'arw', 'dng', '3fr', 'ari',
	'bay', 'ciff', 'crw', 'cs1', 'dc2', 'dcr', 'dcs', 'dng', 'drf', 'eip', 'erf', 'fff', 'gpr',
	'iiq', 'k25', 'kc2', 'kdc', 'mdc', 'mef', 'mos', 'mrw', 'nef', 'nrw', 'obm', 'orf', 'pef',
	'ptx', 'pxn', 'r3d', 'raf', 'raw', 'rwl', 'rw2', 'rwz', 'sr2', 'srf', 'srw', 'tif', 'x3f']

pub enum FileFormat {
	unknown
	raw
	ldr
}

pub struct ManagedImage {
pub mut:
	// unique identifier
	path   string
	image  ?Image
	status LoadStatus
}

pub fn (img ManagedImage) get_file_format() FileFormat {
	if img.path.len == 0 {
		return FileFormat.unknown
	}

	// get the file extension
	extension := img.path.split('.').last().to_lower()

	// check if the extension is a supported raw file type
	if supported_raw_file_types_str.any(it == extension) {
		return FileFormat.raw
	}

	// check if the extension is a supported ldr file type
	if supported_ldr_file_types.any(it == extension) {
		return FileFormat.ldr
	}

	return FileFormat.unknown
}

pub struct Catalog {
pub mut:
	images []ManagedImage
}

pub fn Catalog.new() Catalog {
	return Catalog{
		images: []ManagedImage{}
	}
}

pub fn (mut catalog Catalog) parallel_load_images_by_path(paths []string) {
	file_chan := chan string{cap: 1000}
	managed_image_chan := chan ManagedImage{cap: 1000}

	// create a worker to load image paths
	spawn fn [paths, file_chan] () {
		for path in paths {
			file_chan <- path
		}
		file_chan.close()
	}()

	// create workers to load images
	spawn spawn_load_image_workers(managed_image_chan, file_chan)

	// create worker to collect images
	spawn fn [mut catalog, managed_image_chan] () {
		for {
			managed_image := <-managed_image_chan or { break }

			// find the image in the catalog
			mut found := false
			for mut img in catalog.images {
				if img.path == managed_image.path {
					img.image = managed_image.image
					img.status = managed_image.status
					found = true
					break
				}
			}

			// if the image was not found, add it to the catalog
			if !found {
				catalog.images << managed_image
			}
		}
	}()
}

pub fn spawn_load_image_workers(managed_image_chan chan ManagedImage, filepath_chan chan string) {
	mut wg := sync.new_waitgroup()
	cpus := runtime.nr_cpus()
	workers := math.max(cpus - 4, 1)
	wg.add(workers)
	for j := 0; j < workers; j++ {
		spawn fn [filepath_chan, mut wg, managed_image_chan] () {
			for {
				filepath := <-filepath_chan or { break }
				println('loading image: ${filepath}')
				mi := ManagedImage{
					path:   filepath
					status: LoadStatus.loading
				}
				managed_image_chan <- mi
				match mi.get_file_format() {
					.ldr {
						image := load_image(filepath)
						managed_image_chan <- ManagedImage{
							path:   filepath
							image:  image
							status: LoadStatus.loaded
						}
					}
					.raw {
						image := load_image_raw(filepath)
						managed_image_chan <- ManagedImage{
							path:   filepath
							image:  image
							status: LoadStatus.loaded
						}
					}
					else {
						panic('unsupported file format')
					}
				}
			}
			wg.done()
		}()
	}

	wg.wait()
	managed_image_chan.close()
}
