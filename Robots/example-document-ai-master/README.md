# `RPA.DocumentAI`: Intelligent Document Processing with various engines

Currently supported engines:
- Google: `google`
- Base64: `base64ai`
- Nanonets: `nanonets`


## Tasks

Process a real world PDF [invoice](./devdata/parallels.pdf) (or its PNG
[counterpart](./devdata/parallels.png)) with the following tasks:
- `Document AI Google`: using **Google** engine
- `Document AI Base64`: using **Base64** engine
- `Document AI Nanonets`: using **Nanonets** engine
- `Document AI All`: using all the available engines
- `Document AI Work Items`: using custom configured engines for multiple files
