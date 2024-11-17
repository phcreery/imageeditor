module imageio

import sync
import runtime
import math

pub enum LoadStatus {
	loading
	loaded
	failed
}

pub struct ManagedImage {
pub mut:
	// unique identifier
	path   string
	image  ?Image
	status LoadStatus
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
				dump('loading image: ${filepath}')
				managed_image_chan <- ManagedImage{
					path:   filepath
					status: LoadStatus.loading
				}
				image := load_image_raw(filepath)
				managed_image_chan <- ManagedImage{
					path:   filepath
					image:  image
					status: LoadStatus.loaded
				}
			}
			wg.done()
		}()
	}

	wg.wait()
	managed_image_chan.close()
}
