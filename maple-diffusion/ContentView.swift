import SwiftUI

struct ContentView: View {
#if os(iOS)
    let mapleDiffusion = MapleDiffusion(saveMemoryButBeSlower: true)
#else
    let mapleDiffusion = MapleDiffusion(saveMemoryButBeSlower: false)
#endif
    let dispatchQueue = DispatchQueue(label: "Generation")
    @State var steps: Float = 20
    @State var image: Image?
    @State var cgimage: CGImage?
    @State var prompt: String = ""
    @State var negativePrompt: String = ""
    @State var guidanceScale: Float = 7.5
    @State var running: Bool = false
    @State var progressProp: Float = 1
    @State var progressStage: String = "Ready"
    
    func loadModels() {
        dispatchQueue.async {
            running = true
            mapleDiffusion.initModels() { (p, s) -> () in
                progressProp = p
                progressStage = s
            }
            running = false
        }
    }
  
    func writeImageToPasteboard(img: NSImage) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([img])
    }
    
    func generate() {
        dispatchQueue.async {
            running = true
            progressStage = ""
            progressProp = 0
            mapleDiffusion.generate(prompt: prompt, negativePrompt: negativePrompt, seed: Int.random(in: 1..<Int.max), steps: Int(steps), guidanceScale: guidanceScale) { (cgim, p, s) -> () in
                if (cgim != nil) {
                    cgimage = cgim
                    image = Image(cgim!, scale: 1.0, label: Text("generated image"))
                }
                progressProp = p
                progressStage = s
            }
            running = false
        }
    }
    var body: some View {
        VStack {
#if os(iOS)
            Text("🍁 maple diffusion").foregroundColor(.orange).bold().frame(alignment: Alignment.center)
#endif
            if (image == nil) {
                Rectangle().fill(.gray).aspectRatio(1.0, contentMode: .fit)
                    .frame(idealWidth: mapleDiffusion.width as? CGFloat, idealHeight: mapleDiffusion.height as? CGFloat)
                    .cornerRadius(16)
                    .padding()
            } else {
#if os(iOS)
                ShareLink(item: image!, preview: SharePreview(prompt, image: image!)) {
                    image!.resizable().aspectRatio(contentMode: .fit)
                    .frame(idealWidth: mapleDiffusion.width as? CGFloat, idealHeight: mapleDiffusion.height as? CGFloat)
                    .cornerRadius(16)
                    .padding()
                }
#else
                image!.resizable().aspectRatio(contentMode: .fit)
                    .frame(idealWidth: mapleDiffusion.width as? CGFloat, idealHeight: mapleDiffusion.height as? CGFloat)
                    .cornerRadius(16)
                    .padding()
#endif
            }
            HStack {
                Text("Prompt").bold()
                TextField("What you want", text: $prompt)
            }
            HStack {
                Text("Negative Prompt").bold()
                TextField("What you don't want", text: $negativePrompt)
            }
            HStack {
                HStack {
                    Text("Scale").bold()
                    Text(String(format: "%.1f", guidanceScale)).foregroundColor(.secondary)
                }.frame(width: 96, alignment: .leading)
                Slider(value: $guidanceScale, in: 1...20)
            }
            HStack {
                HStack {
                    Text("Steps").bold()
                    Text("\(Int(steps))").foregroundColor(.secondary)
                }.frame(width: 96, alignment: .leading)
                Slider(value: $steps, in: 5...150)
            }
            ProgressView(progressStage, value: progressProp, total: 1).opacity(running ? 1 : 0).foregroundColor(.secondary)
            Spacer(minLength: 6)
            HStack {
                Button(action: generate) { Text("generate image") }
                    .disabled(running)
                    .cornerRadius(6.0)
                    .padding()
#if os(macOS)
              Button(action: {
                writeImageToPasteboard(img: NSImage(cgImage: cgimage!, size: .zero))
              }) { Text("copy image to clipboard") }
                 .disabled(cgimage == nil && running)
                 .cornerRadius(6.0)
                 .padding()

#endif
            }
        }.padding(16).onAppear(perform: loadModels)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
