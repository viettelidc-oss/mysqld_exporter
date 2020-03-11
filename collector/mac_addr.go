// Copyright 2018 The Prometheus Authors
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package collector

import (
	"context"
	"database/sql"
	"github.com/go-kit/kit/log"
	"github.com/prometheus/client_golang/prometheus"
	"net"
)

const (
	hosts = "MAC_hosts"
)

// Metric descriptors.
var (
	MacAddrHostsInfo = prometheus.NewDesc(
		prometheus.BuildFQName(namespace, heartbeat, "mysql_mac_hosts_info"),
		"Information about running macAddress",
		[]string{"mac_host"}, nil,
	)
)

// MacAddrHosts scrapes metrics about the replicating slaves.
type MacAddrHosts struct{}

// Name of the Scraper. Should be unique.
func (MacAddrHosts) Name() string {
	return hosts
}

// Help describes the role of the Scraper.
func (MacAddrHosts) Help() string {
	return "Scrape information from MAC Address of VM"
}

// Version of MACAddress from which scraper is available.
func (MacAddrHosts) Version() float64 {
	return 1.0
}

func getMacAdd() string {
	ifaces, err := net.Interfaces()
	if err != nil {
		panic("Failed to parse interface")
	}
	for _, i := range ifaces {
		macAdd := i.HardwareAddr.String()
		nameIf := i.Name
		if "ens3" == nameIf {
			return macAdd
		}
	}
	return ""
}

func (MacAddrHosts) Scrape(ctx context.Context, db *sql.DB, ch chan<- prometheus.Metric, logger log.Logger) error {
	macHosts := getMacAdd()

	ch <- prometheus.MustNewConstMetric(
		MacAddrHostsInfo,
		prometheus.GaugeValue,
		1,
		macHosts,
	)
	return nil
}
var _ Scraper = MacAddrHosts{}
