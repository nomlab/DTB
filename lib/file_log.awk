{
    if($5 !~ /\/.emacs.d\// && $5 !~ /\/Emacs.app\// && $5 !~ /\/var\// &&
       $5 !~ /\/System\// && $5 !~ /\/Library\// && $5 !~ /\/dev\// &&
       $5 !~ /\/usr\// && $5 !~ /\/.vol\//)
    {
        print $5, $6
        system("")
    }
}
