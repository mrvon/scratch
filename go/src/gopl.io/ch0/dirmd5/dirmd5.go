package main

import (
	"crypto/md5"
	"fmt"
	"image/png"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
)

func filterDir(dir string) bool {
	if dir == ".git" || dir == ".svn" {
		return true
	} else {
		return false
	}
}

func filterType(file string) bool {
	return true
}

func walkDir(dir string, callback func(filename string)) {
	for _, entry := range dirents(dir) {
		if entry.IsDir() {
			if filterDir(entry.Name()) {
				continue
			}
			subDir := filepath.Join(dir, entry.Name())
			walkDir(subDir, callback)
		} else {
			filename := filepath.Join(dir, entry.Name())

			callback(filename)
		}
	}
}

func dirents(dir string) []os.FileInfo {
	entries, err := ioutil.ReadDir(dir)
	if err != nil {
		return nil
	}
	return entries
}

func main() {
	root_dir := "/home/dennis/skynet"
	md5_file := "/home/dennis/md5.lua"
	png_file := "/home/dennis/map.bin"

	var md5_map = make(map[string]string)
	var hw_list = make([]string, 0)

	walkDir(root_dir, func(filename string) {
		f, err := os.Open(filename)
		if err != nil {
			return
		}

		data, err := ioutil.ReadAll(f)
		if err != nil {
			return
		}

		file_str := fmt.Sprintf("%q", filename)

		md5_str := fmt.Sprintf("\"%x\"", md5.Sum(data))
		md5_map[file_str] = md5_str

		reader := strings.NewReader(string(data))
		conf, err := png.DecodeConfig(reader)
		if err != nil {
			return
		}

		hw_list = append(hw_list, fmt.Sprintf("%s %d %d", file_str, conf.Height, conf.Width))

		f.Close()
	})

	f, err := os.Create(md5_file)
	if err != nil {
		log.Fatal(err)
		return
	}

	fmt.Fprint(f, "return {\n")

	for k, v := range md5_map {
		fmt.Fprint(f, "\t[")
		fmt.Fprint(f, k)
		fmt.Fprint(f, "]")
		fmt.Fprint(f, " = ")
		fmt.Fprint(f, v)
		fmt.Fprint(f, ",\n")
	}

	fmt.Fprint(f, "}\n")

	f.Close()

	f, err = os.Create(png_file)
	if err != nil {
		log.Fatal(err)
		return
	}

	for i := range hw_list {
		fmt.Fprintln(f, i)
	}

	f.Close()
}
