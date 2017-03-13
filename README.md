# vvv-sync-db

Sync [Varying Vagrant Vagrants](https://github.com/Varying-Vagrant-Vagrants/VVV) environments between machines.

## How to install

1. Follow the installation instructions on [VVV](https://varyingvagrantvagrants.org/).
1. Add the following directly below `if defined? VagrantPlugins::Triggers`:
    
    ```
    config.trigger.after :up, :stdout => true do
        info "Importing databases..."
        run_remote "bash /srv/database/sync-sql.sh"
    end
    ```
    Look at `Vagrantfile-example` for an example.
1. Copy `config/homebin/vagrant_halt_custom`, `database/sync-sql.sh`, and `provision/provision-post.sh` to their corresponding directories.
1. If using [Resilio Sync](https://www.resilio.com/individuals/), add the following to `.sync/IgnoreList`:
    ```
    # Vagrant
    .vagrant
    .debris

    # Development
    node_modules
    bower_components
    ```
1. `vagrant up --provision`
1. Halt the 1st machine then repeat steps on 2nd machine

## Process

1. Machine 1 (with vagrant running) - run `vagrant halt`
1. Machine 2 - run `vagrant up` - this will import the db's that are synced. (Note: If you've added a new site, make sure you run vagrant up --provision on the other machine.)
