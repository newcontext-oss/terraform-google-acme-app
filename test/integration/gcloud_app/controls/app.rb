# frozen_string_literal: true

control "instance" do
  describe command('gcloud compute instances describe app') do
    its('stdout') { should match (/name: app/) }
    its('stdout') { should match (/key: block-project-ssh-keys.*value: 'TRUE'/m) }
    its('stdout') { should match (/- key: sshKeys/) }
    its('stdout') { should match (/- key: startup-script/) }
    its('stdout') { should match (/status: RUNNING/) }
    its('stdout') { should match (/tags:.*items:.*- app/m) }
    its('stdout') { should match (/zone:.*zones\/us-west1-a/) }
    its('stdout') { should match (/labels:.*name: app/m) }
  end
end

control "firewall" do
  describe command('gcloud compute firewall-rules describe app-tcp22-ingress') do
    its('stdout') { should match (/allowed:.*- IPProtocol: tcp.*ports:.*- '22'/m) }
    its('stdout') { should match (/direction: INGRESS/) }
    its('stdout') { should match (/network:.*global\/networks\/test-org/) }
    its('stdout') { should match (/priority: 999/) }
    its('stdout') { should match (/targetTags:.*- app/m) }
  end

  describe command('gcloud compute firewall-rules describe app-tcp80-ingress') do
    its('stdout') { should match (/allowed:.*- IPProtocol: tcp.*ports:.*- '80'/m) }
    its('stdout') { should match (/direction: INGRESS/) }
    its('stdout') { should match (/network:.*global\/networks\/test-org/) }
    its('stdout') { should match (/priority: 998/) }
    its('stdout') { should match (/targetTags:.*- app/m) }
  end

  describe command('gcloud compute firewall-rules describe app-to-db-tcp28015-ingress') do
    its('stdout') { should match (/allowed:.*- IPProtocol: tcp.*ports:.*- '28015'/m) }
    its('stdout') { should match (/direction: INGRESS/) }
    its('stdout') { should match (/network:.*global\/networks\/test-org/) }
    its('stdout') { should match (/priority: 997/) }
    its('stdout') { should match (/sourceTags:.*- app/m) }
    its('stdout') { should match (/targetTags:.*- db/m) }
  end
end
