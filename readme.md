# dotfiles

### Description
Repository for keeping track of some of my personal ([@dherslof](https://github.com/dherslof])) basic dotfiles and well used tools. 


**Note:** The `install script` is hard coded for Ubuntu (debian) - uses `apt` for package installation 

### Contains 
* vimrc
* tmux config
* cargo tools list
* zsh
* Personal shell alias list
* [powerline](https://github.com/powerline/powerline) setup

### Installation and usage
Clone the repository.
```bash
$ git clone <github_path>
```

Run the installation script. 
```bash
$ cd dotfiles
$ ./install.sh
```

Only setup tmux:
```bash 
$ ./install.sh -t
```

**Note**: running script without arguments will trigger full installation. For available installation options, see the install help.
```bash
$ ./install.sh -h 
```

In alternative to run the above installation script, is to  manually move/link the dotfiles directly from the `files` directory.

### Todos
Todo list:
