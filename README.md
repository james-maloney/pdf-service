# wkhtmltopdf kubernetes service template

Template used to setup wkhtmltopdf as a Kubernetes service. The service defaults to internal use only.

Uses https://hub.docker.com/r/openlabs/docker-wkhtmltopdf-aas/ as the docker image

*NOTE: Your HTML document must use absolute links (http://) for all images, stylesheets and scripts*

## Setup

Add your GCE project ID to the `rc.yaml`, `service.yaml` and `Makefile` where you see "replace with project id"

## Run

	make

Pulls down the docker image and creates the Kubernetes service and replication controller.

### Example Go client pkg

```go
	package pdfgen

	import (
		"bytes"
		"encoding/base64"
		"encoding/json"
		"fmt"
		"io/ioutil"
		"net/http"
	)

	// ServiceUrl is the url that hosts the wkhtmltopdf service
	var ServiceUrl = "http://pdf-service/"

	type body struct {
		Contents string `json:"contents"`
	}

	// HtmlToPdf converts HTML to a PDF
	func HtmlToPdf(b []byte) ([]byte, error) {
		bd := body{
			Contents: base64.StdEncoding.EncodeToString(b),
		}

		b, err := json.Marshal(bd)
		if err != nil {
			return nil, err
		}

		req, err := http.NewRequest("POST", ServiceUrl, bytes.NewReader(b))
		if err != nil {
			return nil, err
		}

		req.Header.Set("Content-Type", "application/json")

		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			return nil, err
		}
		defer resp.Body.Close()

		b, err = ioutil.ReadAll(resp.Body)
		if err != nil {
			return nil, err
		}

		if resp.StatusCode != 200 {
			fmt.Println("body:", string(b))
			return nil, fmt.Errorf("Non 200 response")
		}

		return b, nil
	}

	// Serve serves the pdf to the browser
	func Serve(w http.ResponseWriter, filename string, pdf []byte) {
		w.Header().Set("Content-Type", "applicaiton/pdf")
		w.Header().Set("Content-Disposition", "attachment; filename="+filename)

		w.Write(pdf)
	}

```
