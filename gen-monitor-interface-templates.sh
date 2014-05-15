#!/bin/bash
#monitor interfaces [type] [name] traffic
#monitor interfaces [type] [name] traffic flow
#monitor interfaces [type] [name] traffic save [filename]
#monitor interfaces [type] [name] traffic save [filename] size [number]
#monitor interfaces [type] [name] traffic save [filename] size [number] files [number]
#monitor interfaces [type] [name] traffic detail
#monitor interfaces [type] [name] traffic detail filter
#monitor interfaces [type] [name] traffic detail unlimited
#monitor interfaces [type] [name] traffic detail unlimited filter
#monitor interfaces [type] [name] traffic filter
#monitor interfaces [type] [name] traffic unlimited
#monitor interfaces [type] [name] traffic unlimited filter

declare -a types=(
       "bonding" \
       "bridge" \
       "ethernet" \
       "loopback" \
       "pseudo-ethernet" \
       "tunnel" \
       "vrrp" \
       "vti" \
       "dummy" \
       "l2tpv3" \
       "pptp-client" \
       "pppoe"
)

TEMPLATE_DIR=generated-templates/monitor/interfaces
mkdir -p $TEMPLATE_DIR
cd $TEMPLATE_DIR

for type in "${types[@]}"; do
  mkdir -p $type/node.tag/flow
  mkdir -p $type/node.tag/traffic/save/node.tag/size/node.tag/files/node.tag
  mkdir -p $type/node.tag/traffic/detail/filter/node.tag
  mkdir -p $type/node.tag/traffic/detail/unlimited/filter/node.tag
  mkdir -p $type/node.tag/traffic/filter/node.tag
  mkdir -p $type/node.tag/traffic/unlimited/filter/node.tag

  # node.tag
  echo "help: Monitor specified $type interface" >| $type/node.tag/node.def
  echo "allowed: \${vyatta_sbindir}/vyatta-interfaces.pl --show $type" >> $type/node.tag/node.def
  echo 'run: bmon -p $4' >> $type/node.tag/node.def

  # flow
  echo 'help: Monitor flows on specified interface' >| $type/node.tag/flow/node.def
  echo 'run: sudo /usr/sbin/iftop -i $4' >> $type/node.tag/flow/node.def

  # traffic
  echo "help: Montior captured traffic on specified $type interface" >| $type/node.tag/traffic/node.def
  echo 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4' >> $type/node.tag/traffic/node.def

  # traffic save
  echo 'help: Save monitored traffic to a file' >| $type/node.tag/traffic/save/node.def
  echo 'help: Save monitored traffic to the specified file' >| $type/node.tag/traffic/save/node.tag/node.def
  echo "allowed: echo -e '<name>.pcap'" >>  $type/node.tag/traffic/save/node.tag/node.def
  echo 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4 --save "${@:7}"' >>  $type/node.tag/traffic/save/node.tag/node.def

  # traffic save size
  echo 'help: Save monitored traffic to a file with max size' >| $type/node.tag/traffic/save/node.tag/size/node.def
  echo "help: Maximum file size (e.g., 1 = 1 KiB, 1M = 1 MiB)" >| $type/node.tag/traffic/save/node.tag/size/node.tag/node.def
  echo "allowed: echo -e '<number>'" >> $type/node.tag/traffic/save/node.tag/size/node.tag/node.def
  echo 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4 --save "${@:7}" --size "${@:9}"' >> $type/node.tag/traffic/save/node.tag/size/node.tag/node.def

  # traffic save size files
  echo 'help: Save monitored traffic to a set of rotated file' >| $type/node.tag/traffic/save/node.tag/size/node.tag/files/node.def
  echo 'help: Number of files to rotate stored traffic through' >| $type/node.tag/traffic/save/node.tag/size/node.tag/files/node.tag/node.def
  echo "allowed: echo -e '<number>'" >> $type/node.tag/traffic/save/node.tag/size/node.tag/files/node.tag/node.def
  echo 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4 --save "${@:7}" --size "${@:9}" --files "${@:11}"' >> $type/node.tag/traffic/save/node.tag/size/node.tag/files/node.tag/node.def

  # traffic detail
  echo -e "help: Monitor detailed traffic for the specified $type interface" >| $type/node.tag/traffic/detail/node.def
  echo -e 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4 --detail' >> $type/node.tag/traffic/detail/node.def

  # traffic detail filter
  echo "help: Monitor detailed filtered traffic for the specified $type interface" >| $type/node.tag/traffic/detail/filter/node.def
  echo -e "help: Monitor detailed filtered traffic for the specified $type interface" >| $type/node.tag/traffic/detail/filter/node.tag/node.def
  echo -e "allowed: echo -e '<pcap-filter>'" >> $type/node.tag/traffic/detail/filter/node.tag/node.def
  echo 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4 --detail --filter "${@:8}"' >> $type/node.tag/traffic/detail/filter/node.tag/node.def

  # traffic detail unlimited
  echo -e "help: Monitor detailed traffic for the specified $type interface" >| $type/node.tag/traffic/detail/unlimited/node.def
  echo 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4 --detail --unlimited' >> $type/node.tag/traffic/detail/unlimited/node.def

  # traffic detail unlimited filter
  echo "help: Monitor detailed filtered traffic for the specified $type interface" >| $type/node.tag/traffic/detail/unlimited/filter/node.def
  echo "help: Monitor detailed filtered traffic for the specified $type interface" >| $type/node.tag/traffic/detail/unlimited/filter/node.tag/node.def
  echo "allowed: echo -e '<pcap-filter>'" >> $type/node.tag/traffic/detail/unlimited/filter/node.tag/node.def
  echo 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4 --detail --unlimited --filter "${@:9}"' >> $type/node.tag/traffic/detail/unlimited/filter/node.tag/node.def

  # traffic filter
  echo "help: Monitor filtered traffic for the specified $type interface" >| $type/node.tag/traffic/filter/node.def
  echo "help: Monitor filtered traffic for the specified $type interface" >| $type/node.tag/traffic/filter/node.tag/node.def
  echo "allowed: echo -e '<pcap-filter>'" >> $type/node.tag/traffic/filter/node.tag/node.def
  echo 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4 --filter "${@:7}"' >> $type/node.tag/traffic/filter/node.tag/node.def

  # traffic unlimited
  echo "help: Monitor traffic for the specified $type interface" >| $type/node.tag/traffic/unlimited/node.def
  echo 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4 --unlimited' >> $type/node.tag/traffic/unlimited/node.def

  # traffic unlimited filter
  echo "help: Monitor filtered traffic for the specified $type interface" >| $type/node.tag/traffic/unlimited/filter/node.def
  echo "help: Monitor filtered traffic for the specified $type interface" >| $type/node.tag/traffic/unlimited/filter/node.tag/node.def
  echo "allowed: echo -e '<pcap-filter>'" >> $type/node.tag/traffic/unlimited/filter/node.tag/node.def
  echo 'run: ${vyatta_bindir}/vyatta-tshark.pl --intf $4 --unlimited --filter "${@:8}"' >> $type/node.tag/traffic/unlimited/filter/node.tag/node.def

done

# Overrides
# This is where specific tweaks to the above can be made

# loopback
sed -i -e 's;run: bmon -p $4;;' loopback/node.tag/node.def

# vti
rm -rf vti/node.tag/flow

# VRRP
sed -i -e 's;allowed: ${vyatta_sbindir}/vyatta-interfaces.pl --show vrrp;allowed: ${vyatta_bindir}/vyatta-show-interfaces.pl --vrrp --action=allowed;' vrrp/node.tag/node.def
