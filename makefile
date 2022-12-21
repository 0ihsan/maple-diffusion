all: app

app: sd
	mkdir -p sd.app/Contents/MacOS
	mkdir -p sd.app/Contents/Resources
	printf '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n	<key>CFBundleExecutable</key><string>sd</string>\n	<key>CFBundlePackageType</key><string>APPL</string>\n</dict>\n</plist>\n' > sd.app/Contents/Info.plist
	cp -pr sd sd.app/Contents/MacOS/sd
	[ -d sd.app/Contents/Resources/bins ] || cp -pr bins sd.app/Contents/Resources

sd:
	swiftc -o sd **/*.swift
	
clean:
	rm -rf sd