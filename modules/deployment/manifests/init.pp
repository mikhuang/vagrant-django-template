class deployment {

    $deploy_user = "deployer"
    $deploy_group = "www-data"
    
    user {$deploy_user:
        name       => $deploy_user,
        gid        =>  $deploy_group,
        home       => "/home/$deploy_user",
        shell      => "/bin/bash",
        managehome => true,
        ensure     => "present",
    }
    
    # Add the user to sudoers by setting 
    # the /etc/sudoers file.
    file { "sudoers":
        path => "/etc/sudoers",
        owner => root,
        group => root,
        mode => 440,
        content => template("deployment/etc/sudoers.erb"),
    }

    file { "ssh-directory":
        path    => "/home/$deploy_user/.ssh",
        ensure  => directory,
        owner   => $deploy_user,
        group   => $deploy_group,
        mode    => 755,
        require => User[$deploy_user],
    }

    file { "ssh-authorized-keys":
        path    => "/home/$deploy_user/.ssh/authorized_keys",
        ensure  => present,
        owner   => $deploy_user,
        group   => $deploy_group,
        mode    => 644,
        source  => "puppet:///modules/deployment/ssh/authorized_keys",
        require => File["ssh-directory"],
    }

    file { "ssh-known-hosts":
        path    => "/home/$deploy_user/.ssh/known_hosts",
        ensure  => present,
        owner   => $deploy_user,
        group   => $deploy_group,
        mode    => 644,
        source  => "puppet:///modules/deployment/ssh/known_hosts",
        require => File["ssh-directory"],
    }

    file { "ssh-private-key":
        path    => "/home/$deploy_user/.ssh/id_rsa",
        ensure  => present,
        owner   => $deploy_user,
        group   => $deploy_group,
        mode    => 600,
        source  => "puppet:///modules/deployment/ssh/id_rsa",
        require => File["ssh-directory"],
    }

    file { "ssh-public-key":
        path    => "/home/$deploy_user/.ssh/id_rsa.pub",
        ensure  => present,
        owner   => $deploy_user,
        group   => $deploy_group,
        mode    => 644,
        source  => "puppet:///modules/deployment/ssh/id_rsa.pub",
        require => File["ssh-directory"],
    }

    # Now we make the project install script.
    file { "install_${full_project_name}.sh":
        path => "/home/$deploy_user/install_${full_project_name}.sh",
        owner => $deployer_user,
        group => $deploy_group,
        mode => 775,
        content => template("deployment/home/install_project.sh.erb"),
        require => User[$deploy_user],
    }

}
