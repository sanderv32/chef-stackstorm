require 'spec_helper'

describe 'stackstorm::user' do
  platforms = {
    'ubuntu' => ['14.04'],
    'centos' => ['7.0'],
  }

  platforms.each do |platform, versions|
    versions.each do |version|
      let(:chef_run) { ChefSpec::SoloRunner.new(platform: platform, version: version).converge(described_recipe) }

      context "Using #{platform} #{version} with default node attributes" do
        it 'should create user "stanley"' do
          expect(chef_run).to create_user('stanley').with(
            home: '/home/stanley',
            manage_home: true
          )
        end

        it 'should create directory "creating /home/stanley/.ssh directory for stanley"' do
          expect(chef_run).to create_directory('creating /home/stanley/.ssh directory for stanley').with(
            path: '/home/stanley/.ssh',
            owner: 'stanley',
            group: 'stanley',
            mode: 0700
          )
        end

        it 'should run execute "generating ssh key-pair for stanley"' do
          expect(chef_run).to run_execute('generating ssh key-pair for stanley').with(
            command: "ssh-keygen -f /home/stanley/.ssh/id_rsa -b 2048 -P ''",
            user: 'stanley',
            group: 'stanley'
          )
        end

        it 'should not run execute "generating ssh key-pair for stanley" if ssh key already exists' do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with('/home/stanley/.ssh/id_rsa').and_return(true)
          expect(chef_run).to_not run_execute('generating ssh key-pair for stanley').with(
            command: "ssh-keygen -f /home/stanley/.ssh/id_rsa -b 2048 -P ''",
            user: 'stanley',
            group: 'stanley'
          )
        end

        it 'should not create file "creating /home/stanley/.ssh/id_rsa key stanley"' do
          expect(chef_run).to_not create_file('creating /home/stanley/.ssh/id_rsa key stanley')
        end

        it 'should not create file "creating /home/stanley/.ssh/id_rsa public key for stanley"' do
          expect(chef_run).to_not create_file('creating /home/stanley/.ssh/id_rsa public key for stanley')
        end

        it 'should create file "creating /home/stanley/.ssh/authorized_keys for stanley"' do
          allow(IO).to receive(:read).and_call_original
          allow(IO).to receive(:read).with('/home/stanley/.ssh/id_rsa.pub').and_return('ssh-rsa fake-key')
          expect(chef_run).to create_file('creating /home/stanley/.ssh/authorized_keys for stanley').with(
            path: '/home/stanley/.ssh/authorized_keys',
            owner: 'stanley',
            group: 'stanley',
            mode: 0644,
            content: "# Generated by Chef. Don't edit!\nssh-rsa fake-key"
          )
        end

        it 'should install sudo "stanley"' do
          expect(chef_run).to install_sudo('stanley').with(
            user: 'stanley',
            nopasswd: true
          )
        end
      end

      context "Using #{platform} #{version} with node['stackstorm']['user']['enable_sudo'] = false" do
        it 'should not install sudo "stanley"' do
          chef_run.node.normal['stackstorm']['user']['enable_sudo'] = false
          chef_run.converge(described_recipe)
          expect(chef_run).to_not install_sudo('stanley')
        end
      end

      context "Using #{platform} #{version} with node['stackstorm']['user']['ssh_key'] not nil" do
        it 'should create file "creating /home/stanley/.ssh/id_rsa key stanley"' do
          chef_run.node.normal['stackstorm']['user']['ssh_key'] = 'fake ssh key'
          chef_run.converge(described_recipe)
          expect(chef_run).to create_file('creating /home/stanley/.ssh/id_rsa key stanley').with(
            path: '/home/stanley/.ssh/id_rsa',
            mode: 0640,
            user: 'stanley',
            group: 'stanley',
            content: 'fake ssh key'
          )
        end

        it 'should not create file "creating /home/stanley/.ssh/id_rsa public key for stanley"' do
          chef_run.node.normal['stackstorm']['user']['ssh_key'] = 'fake ssh key'
          chef_run.converge(described_recipe)
          expect(chef_run).to_not create_file('creating /home/stanley/.ssh/id_rsa public key for stanley')
        end
      end

      context "Using #{platform} #{version} with node['stackstorm']['user']['ssh_key'] and ['stackstorm']['user']['ssh_pub'] not nil" do
        it 'should create file "creating /home/stanley/.ssh/id_rsa key stanley"' do
          chef_run.node.normal['stackstorm']['user']['ssh_key'] = 'fake ssh key'
          chef_run.node.normal['stackstorm']['user']['ssh_pub'] = 'fake ssh public key'
          chef_run.converge(described_recipe)
          expect(chef_run).to create_file('creating /home/stanley/.ssh/id_rsa key stanley').with(
            path: '/home/stanley/.ssh/id_rsa',
            mode: 0640,
            user: 'stanley',
            group: 'stanley',
            content: 'fake ssh key'
          )
        end

        it 'should create file "creating /home/stanley/.ssh/id_rsa public key for stanley"' do
          chef_run.node.normal['stackstorm']['user']['ssh_key'] = 'fake ssh key'
          chef_run.node.normal['stackstorm']['user']['ssh_pub'] = 'fake ssh public key'
          chef_run.converge(described_recipe)
          expect(chef_run).to create_file('creating /home/stanley/.ssh/id_rsa public key for stanley').with(
            path: '/home/stanley/.ssh/id_rsa.pub',
            user: 'stanley',
            group: 'stanley',
            content: 'fake ssh public key'
          )
        end
      end
    end
  end
end
