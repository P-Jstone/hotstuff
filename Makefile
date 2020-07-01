proto_include := $(shell go list -m -f {{.Dir}} github.com/relab/gorums)
proto_src := clientapi/hotstuff.proto gorumshotstuff/internal/proto/hotstuff.proto
proto_go := $(proto_src:%.proto=%.pb.go)
gorums_go := $(proto_src:%.proto=%_gorums.pb.go)

binaries := cmd/hotstuffclient/hotstuffclient cmd/hotstuffserver/hotstuffserver cmd/hotstuffkeygen/hotstuffkeygen

.PHONY: all $(binaries)

all: $(binaries)

debug: GCFLAGS += -gcflags='all=-N -l'
debug: $(binaries)

download:
	@go mod download

$(gorums_go) $(proto_go): download

%.pb.go %_gorums.pb.go : %.proto
	@protoc -I=$(proto_include):. \
		--go_out=paths=source_relative:. \
		--gorums_out=paths=source_relative:. \
		$<

$(binaries): $(proto_go) $(gorums_go)
	@go build -o ./$@ ./$(dir $@)
