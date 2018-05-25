# frozen_string_literal: true

allow_ssh_ingress_firewall_rule_name = attribute "allow_ssh_ingress_firewall_rule_name", {}
allow_http_ingress_firewall_rule_name = attribute "allow_http_ingress_firewall_rule_name", {}
allow_data_ingress_to_db_firewall_rule_name = attribute "allow_data_ingress_to_db_firewall_rule_name", {}
app_name = attribute "app_name", {}
network_name = attribute "network_name", {}

control "instance" do
  describe "application" do
    subject do
      command "gcloud compute instances describe #{app_name} --zone us-west1-a"
    end

    its('stdout') { should match (/key: block-project-ssh-keys.*value: 'TRUE'/m) }
    its('stdout') { should match (/- key: sshKeys/) }
    its('stdout') { should match (/- key: startup-script/) }
    its('stdout') { should match (/status: RUNNING/) }
    its('stdout') { should match (/tags:.*items:.*- app/m) }
    its('stdout') { should match (/labels:.*name: app/m) }
  end
end

control "firewall" do
  describe "allow SSH ingress to application" do
    subject do
      command "gcloud compute firewall-rules describe #{allow_ssh_ingress_firewall_rule_name}"
    end

    its('stdout') { should match (/allowed:.*- IPProtocol: tcp.*ports:.*- '22'/m) }
    its('stdout') { should match (/direction: INGRESS/) }
    its('stdout') { should match (/network:.*global\/networks\/#{network_name}/) }
    its('stdout') { should match (/priority: 999/) }
    its('stdout') { should match (/targetTags:.*- app/m) }
  end

  describe "allow HTTP ingress to application" do
    subject do
      command "gcloud compute firewall-rules describe #{allow_http_ingress_firewall_rule_name}"
    end

    its('stdout') { should match (/allowed:.*- IPProtocol: tcp.*ports:.*- '80'/m) }
    its('stdout') { should match (/direction: INGRESS/) }
    its('stdout') { should match (/network:.*global\/networks\/test-org/) }
    its('stdout') { should match (/priority: 998/) }
    its('stdout') { should match (/targetTags:.*- app/m) }
  end

  describe "allow data ingress to database" do
    subject do
      command "gcloud compute firewall-rules describe #{allow_data_ingress_to_db_firewall_rule_name}"
    end

    its('stdout') { should match (/allowed:.*- IPProtocol: tcp.*ports:.*- '28015'/m) }
    its('stdout') { should match (/direction: INGRESS/) }
    its('stdout') { should match (/network:.*global\/networks\/test-org/) }
    its('stdout') { should match (/priority: 997/) }
    its('stdout') { should match (/sourceTags:.*- app/m) }
    its('stdout') { should match (/targetTags:.*- db/m) }
  end
end
