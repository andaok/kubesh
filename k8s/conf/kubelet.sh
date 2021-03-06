#!/bin/bash


source define.sh

# 1 
# master address
MASTER_ADDRESS="$1"
if [ ! $MASTER_ADDRESS ]; then
  echo "ENTER MASTER_ADDRESS eg:192.168.1.2"
  exit 1
fi

# 2
# node address
NODE_IP="$2"
if [ ! $NODE_IP ]; then
  echo "ENTER NODE_IP eg:192.168.1.100"
  exit 1
fi


# config
echo "kubeconfig..."
bash ./conf/kubeconfig.sh ${MASTER_ADDRESS}



# kubelet service
cat <<EOF >/usr/lib/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \
--address=0.0.0.0 \
--port=10250 \
--hostname-override=${NODE_IP} \
--allow-privileged=false \
--kubeconfig=${WORK_DIR}/config/kubeconfig.conf \
--cluster-dns=${DNS_SERVER_IP} \
--cluster-domain=${CLUSTER_NAME} \
--fail-swap-on=false \
--logtostderr=false \
--log-dir=${LOG_DIR} \
--v=2
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
systemctl status kubelet
