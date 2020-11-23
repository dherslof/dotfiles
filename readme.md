# dotfiles

### Description
Repository for keeping track of some of my personal ([@dherslof](https://github.com/dherslof])) basic dotfiles and well used tools. 


**Note:** The `install script` are hard coded for Ubuntu (debian) - uses `apt` for package installation 

### Contains 
* vimrc
* tmux config
* cargo tools list
* zsh

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

Only install tmux_conf:
```bash 
$ ./install.sh -t
```

**Note**: running script without arguments will trigger full installation. For available installation options, see the install help.
```bash
$ ./install.sh -h 
```

In alternative to run the above installation script, is to  manually move/link the dotfiles directly from the `files` directory.

### Todos
In the future, it would be nice to add some more features in install script! (Today this needs to be done manually)
* [powerline](https://github.com/powerline/powerline)
* [shellcheck](https://github.com/koalaman/shellcheck)


