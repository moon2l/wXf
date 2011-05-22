#Important to call wAx here
require 'wAx'

module WXf
module WXfui
module Console
module Processing


class CoreProcs
  
  attr_accessor :control, :framework, :exploit_opts, :svr, :mpholder
  
  include WXf::WXfui::Console::Operations::ModOperator
 
      def initialize(control)
        super
            self.control = control
            self.framework =  control.framework
      end
    
        
    #
    # Update command
    #  
    def arg_update(*cmd)
     if !cmd.empty?
       control.prnt_err('Please type "update" only') 
       return
      end      
      pwd = Dir.pwd      
      if pwd == WXf::WorkingDir
        exec = ::IO.popen("git pull", "r")
        exec.each do |data|
          print(data)
        end
        exec.close
      else
        control.prnt_err("You need to be in wXf root directory to update")
      end
    end           
      
    
    #
    # This is how we get buby scripts and burp going
    #
    def arg_burp(*cmd)
      if in_focus()
        arg_back()
      end  
      
      operator = BurpProcs
      control.add_activity(operator)
      self.in_focus = framework.modules.load("burp",control)
      control.mod_prm("#{in_focus.type}" + control.red("(config)"))
      control.prnt_gen("Interact with Burp via wXf")      
    end
    
      
    #   
    # When the user types "use" 
    #
    def arg_use(*cmd)
      # This is a module name placeholder so we can reload easily
      self.mpholder = ''
      
      if (cmd.length == 0)
        control.prnt_dbg(" Example: use <module name>\n\n")
           return false
      end 
      arg_name = cmd[0]      
      begin
       
        activity = fw_mod?(arg_name, control)
        
        if activity.nil?
         return false
        end
        
        operator = nil
        
        if activity.respond_to?("type")
          actv_type = activity.type
        end
        
       case (actv_type)
       when BUBY
         operator = BubyProcs  
       when FILE_EXP
         operator = FileExpProcs   
       when AUXILIARY
         operator = AuxiliaryProcs
        else
         control.prnt_err(" Please ensure you are not trying to use a Payload")
         return false
        end
      
      end
        
      in_focus?
       
      if (operator != nil)
        control.add_activity(operator)
      end
      
     self.in_focus = activity  
     
     if auxiliary? or file_exploit?
       #short term workaround
       nickname = arg_name.split('/')
       control.mod_prm("#{activity.type}" + control.red("(#{nickname.last})", true))
     else
       self.mpholder = arg_name
       control.mod_prm("#{activity.type}" + control.red("(#{arg_name.split('/').last})", true))
     end
             
    end
    
    def in_focus?
    if self.in_focus
      arg_back
    end
    end
    

    #
    #
    #
    def fw_mod?(name, control)
      @mod = framework.modules.load(name, control)
      if @mod.nil?
        control.prnt_err(" This is not the module you are looking for: (#{name})") and return nil
      else
        return @mod
      end
    end
   
    
    #
    #These will get shifted around eventually, for now they lighten the load on if/elsif/else type programming
    #
    def auxiliary?
     in_focus.type == 'auxiliary'
    end
        
    def file_exploit?
      in_focus.type == 'file_exploit'
    end
    
    
    #
    # Use tab helper
    #
    def arg_use_comp(str, stra)
     mods = framework.modules.module_list
     return mods
    end
    
    #
    # Suppots the decision making process of which options to set with arg_set.
    #
    def option_name(cmd)
        name_of_opt = cmd
        opt = nil
        
        if (in_focus.type == WEBSERVER) and (in_focus.options.has_key?(name_of_opt))
          opt = 'webserver_options'
        elsif (in_focus.type == CREATE_EXPLOIT) and (in_focus.options.has_key?(name_of_opt))
          opt = 'create_exploit_options'
        elsif (in_focus.type == CREATE_PAYLOAD) and (in_focus.options.has_key?(name_of_opt))
          opt = 'create_payload_options'
        elsif (in_focus.type == AUXILIARY) and (in_focus.options.has_key?(name_of_opt))
          opt = 'auxiliary_options'
        elsif (in_focus.type == BURP) and (in_focus.options.has_key?(name_of_opt)) 
          opt = 'burp_options'
        elsif (in_focus.type == BUBY) and (in_focus.options.has_key?(name_of_opt)) 
          opt = 'buby_options'
        elsif (in_focus.type == FILE_EXP) and (in_focus.options.has_key?(name_of_opt))  
          opt = 'exploit_mod_options'
        elsif (in_focus.respond_to?('pay')) and (in_focus.pay.respond_to?('options')) and (in_focus.pay.optional.has_key?(name_of_opt))
         opt = 'optional_payload'
        elsif (in_focus.respond_to?('pay')) and (in_focus.pay.respond_to?('required')) and (in_focus.pay.required.has_key?(name_of_opt))
          opt = 'required_payload'
        elsif (in_focus.respond_to?('exp')) and (in_focus.exp.respond_to?('optional')) and (in_focus.exp.optional.has_key?(name_of_opt))
          opt = 'optional_exploit'
        elsif (in_focus.respond_to?('exp')) and (in_focus.exp.respond_to?('required')) and (in_focus.exp.required.has_key?(name_of_opt))
          opt = 'required_exploit'
        elsif (name_of_opt == "PAYLOAD")  
          opt = 'PAYLOAD'
        else
          control.prnt_err(" Please enter a valid option, use show options") 
          return false
        end
        
      end
    
      
    #
    # Used to set options and payloads
    #
    def arg_set(*cmd)
      if cmd[1].nil?
              control.prnt_err(" Please enter an option and value")      
       return false 
    end
      
      arg_opt = cmd[0]
   
      if (in_focus) and not (cmd[1].nil?)
          case option_name(cmd[0])    
              when  'optional_payload'
                     cmd.slice!(0)
                     in_focus.pay.optional[arg_opt] = "#{cmd.join(" ")}"       
              when  'required_payload'
                     cmd.slice!(0)
                     in_focus.pay.required[arg_opt] = "#{cmd.join(" ")}"
              when  'optional_exploit'     
                     cmd.slice!(0)
                     in_focus.exp.optional[arg_opt] = "#{cmd.join(" ")}"
              when  'required_exploit'
                     cmd.slice!(0)
                     in_focus.exp.required[arg_opt] = "#{cmd.join(" ")}"
              when  'auxiliary_options' 
                     cmd.slice!(0)
                     in_focus.datahash[arg_opt] = "#{cmd.join(" ")}"  
              when  'exploit_mod_options'
                     cmd.slice!(0)
                     in_focus.datahash[arg_opt] = "#{cmd.join(" ")}"   
              when  'webserver_options'
                     cmd.slice!(0)
                     in_focus.options[arg_opt] =  "#{cmd.join(" ")}" 
              when   'buby_options'       
                     cmd.slice!(0)
                     in_focus.datahash[arg_opt] =  "#{cmd.join(" ")}" 
              when   'burp_options'       
                     cmd.slice!(0)
                     in_focus.options[arg_opt] =  "#{cmd.join(" ")}" 
              when 'create_exploit_options'
                     cmd.slice!(0)
                     in_focus.options[arg_opt] = cmd.join(" ")
              when 'create_payload_options'
                     cmd.slice!(0)
                     in_focus.options[arg_opt] = cmd.join(" ")   
              when  'PAYLOAD'
                     begin
                     
                     if ((assistant = framework.modules.load("#{cmd[1]}",control)) == nil)
                       return false
                     end
                        return false if (assistant == nil)
                        self.active_assist_module = assistant.payload 
                     end
                    
                      if (active_assist_module) and not(in_focus.type == 'auxiliary')
                          self.in_focus.pay = self.active_assist_module
                          control.prnt_plus(" PAYLOAD => #{cmd[1]}")
                     else
                          control.prnt_err(" Incorrect Payload #{cmd[1]}")
                          return false
                      end
            end       
        end  
    end  
    
    
    attr_accessor :active_assist_module
    
    
   #
   # Tab completion when 'set' something has occurred.
   #
   def arg_set_comp(str, stra)
     list = []
       
     if in_focus.nil? 
       return nil
     elsif stra[1] == "PAYLOAD" and in_focus.respond_to?('exp')
       list.concat(framework.modules.payload_array)
     elsif (stra[1] == 'LFILE')
       list.concat(framework.modules.lfile_load_list.keys.sort)
     elsif (stra[1] == 'RURLS')
       list.concat(framework.modules.rurls_load_list.keys.sort)
     elsif (stra[1] == 'UA')
       list.concat(WXf::UA_MAP.keys.sort)
     elsif (stra[1] == 'CONTENT')
       list.concat(WXf::CONTENT_TYPES.keys.sort)
     elsif stra[1] == 'RURL'
       list.concat(POPULAR_URLS)  
     end
       
     
       in_focus.options.each {|k,v| list.push(k)}
    
       return list
   end
    
    
    #
    # Banner is probably obvious, used for displaying a  banner
    #
    def arg_display(*cmd)
      disp =  control.purple(WXf::WXfui::Console::Prints::PrintDisplay.sample + "\n\n")
      disp << " Web Exploitation Framework: #{WXf::Version}\n"
      disp << " The time is currently: #{control.purple(Time.now)}\n\n"
      disp << " wXf has the following available resources:\n\n"
      disp << "-{ #{counter("buby")} buby }-\n"
      disp << "-{ #{counter("exploits")} exploits }-\n"      
      disp << "-{ #{counter("auxiliary")} auxiliary }-\n\n"
      puts disp
    end     
    
 
  #
  # name method is used for controlling the enstacking, destacking
  #
  def name
    "Core"
  end   
  
  #
  # server method is used for setting up the webserver
  # 2010-12-10 --Ken (Bug Fix, added destacking if active_mod exists, updating of prompt,
  # ...pretty printing of the "Manage wXf...")
  #
  def arg_server(*cmd)
    if in_focus()
      arg_back()
    end  
    
    operator = WebserverProcs
    control.add_activity(operator)
    self.in_focus = framework.modules.load("webserver",control)
    control.mod_prm("#{in_focus.type}" + control.red("(config)"))
    control.prnt_gen("Manage wXf web server")
  end
  
  
  
  #
  # *WILL* be used for importing information in xml format
  # 
  def arg_import(*cmd)
   control.prnt_gen(" This is where we will import thing like a burp xml and maybe nikto responses, who knows")
  end      
    
  

#
# Show options, exploits, payloads....used for all of that 
#     
def arg_show(*cmd)
  activity = self.in_focus
  cmd << "all" if (cmd.length == 0)
     case "#{cmd}"
     when 'all'  
      show_auxiliary
      show_exploits
              
     when 'exploits'
      show_exploits
      
     when 'content'
       show_content
       
     when 'rurls'
       show_rurls  
       
     when 'ua'   
       show_ua
       
     when 'lfiles'
       show_lfiles      
      
     when 'auxiliary'
      show_auxiliary
      
     when 'advanced'
       show_content
       show_lfiles
       show_rurls
       show_ua 
      
     when 'options'           
      if (activity) 
          show_options(activity)
      end
      
     else
       control.prnt_dbg(" The following is a list of accepted show commands:\n")
         arg_show_comp(nil, nil).sort.each do |show_cmd|
           puts("#{show_cmd}\n")
        end  
     end
  end 
  
   
    #
    # Show tabs helper
    #
    def arg_show_comp(str,stra)
     activity = self.in_focus
     list = []
     if (activity) 
       list = ["exploits","auxiliary", "options", "lfiles", "ua", "content", "rurls", "advanced"]
     else
       list = ["exploits","auxiliary", "lfiles", "ua", "content", "rurls", "advanced"]
     end
    return list 
    end 
   
    
    
    #
    # Shutdown the webserver instances
    #
    def web_shut
      svr_id = 0
        control.webstack.each { |svr|
          control.prnt_gen("Shutting down #{svr.lhost}:#{svr.lport} (#{svr_id})")
          svr_id = svr_id + 1
          svr.shutdown
        }
        control.webstack = []
    end  
      
    #
    # self-explanatory, just exits the framework
    #
    def arg_exit(*cmd)
      #kill webserver processes
      web_shut
      #obvious
      exit
    end
  
    #
    # Getting annoyed by typing ex and then going into EX mode. Srs bzns.
    #
    alias arg_ex arg_exit
    
    #
    # Used to destack the activities
    #
    def arg_back(*cmd)
                      
          if control.activities.length > 1 and control.infocus_activity.name != 'Core'
            
          if (in_focus)
              self.in_focus = nil
          end  
          if (active_assist_module)
              self.active_assist_module = nil
          end      
              control.remove_activity
              control.mod_prm('')
          end
          
    end   
    
    
    
    #
    # This is used for navigating directories
    #
    def arg_cd(*cmd)
      
        if(cmd.length == 0)
            control.prnt_err " No path specified"
            return
        end
        
        begin
            Dir.chdir(cmd.join(" ").strip)
            control.prnt_gen(" pwd: #{Dir.pwd()}")
        rescue ::Exception
            control.prnt_err(" The specified path does not exist")
        end
  
    end

    
    
    
    #
    # When an in_focus exists this method becomes the de-facto to module specific options
    #
    def show_options(activity)
     case activity.type
     when 'file_exploit'
      activity.usage
     when 'auxiliary'
      activity.usage
     when 'webserver'
      activity.usage
     when 'buby'
       activity.usage
     when 'burp'
       activity.usage
     end       
    end
 
    
    
    #
    # Shows arg_help for every operator on the stack that has the method defined.
    #
    def arg_?(*cmd)
            control.activities.each { |operator|
            next if ((operator.respond_to?('avail_args') == false) or
                     (operator.avail_args == nil) or
                     (operator.avail_args.length == 0))
             
                  # Display the commands
                  tbl = WXf::WXfui::Console::Prints::PrintTable.new(
                    'Title'  => "#{operator.name} Commands",
                    'Justify'  => 4,             
                    'Columns' => 
                      [
                        'Command',
                        'Description'
                      ])
            
                  operator.avail_args.sort.each { |k,v|
                  tbl.add_ritems([k.to_s, v.to_s])
                  }
                 tbl.prnt
      }
     
    end
    
      
    #  
    # Method to show version information. *Would like to shift from Core::Version to constants (maybe)
    #
    def arg_version(*cmd)
      control.prnt_gen("Web Exploitation Framework:" + WXf::Version)
    end
 
    
    #
    # Shows current module on the stack, important when troubleshooting bugs. More for us than the user.
    #
    def arg_current(*cmd)
      puts("#{control.infocus_activity}")
    end
     
    
    #
    # A copy of the method arg_?
    # 
    alias arg_help arg_?
    
    
    #
    # A copy of the method arg_info_comp
    #
    def arg_info_comp(str, stra); arg_use_comp(str, stra); end
    
    #
    # Thanks to CG [carnal0wnage] for mentioning this method. 
    # ...Returns information on a module
    #
    def arg_info(*cmd)
       arg_name = cmd[0]
       
       if cmd.length == 0 and in_focus.nil?
         print(
                   "Example: info <module name>\n\n")
                   return false
       end
      
       if (cmd.length == 0) and (in_focus)
         case in_focus.type
         when 'auxiliary'
           WXf::WXfui::Console::Prints::PrintPretty.collect(in_focus)
         when 'buby'
           WXf::WXfui::Console::Prints::PrintPretty.collect(in_focus)
         end
      end
      
      
      if (cmd.length >= 1)
        if ((mod = framework.modules.load(arg_name, control)) == nil)
                  control.prnt_err(" Non-existent module: #{arg_name}")
                return false
        else
          WXf::WXfui::Console::Prints::PrintPretty.collect(mod)
        end
      end
      
    end
  
  
  
  #
  # Used to reload an object
  #
  def arg_reload(*cmd)
    item = "#{cmd[0]}"     
    unloaded = false
    type_name = ''
    if in_focus
      type_name = in_focus.type
    end
        
    case item
      when "current" 
        if !in_focus
          control.prnt_err("There is no module in use")    
          return
        end
        if type_name.match(/(auxiliary|file_exploit|buby)/)
          name = ''
          mods = framework.modules.mod_pair[type_name]
            mods.each {|k,v| 
              if v == in_focus
                name = k
              end
            }
        full_name = "#{type_name}/#{name}"
        framework.modules.reload(in_focus, full_name)
        arg_use(full_name)
       elsif type_name.match(/(db_exploit)/) 
         web_shut       
         arg_use(self.mpholder)
       elsif type_name.match(/webserver/)
         web_shut
         arg_server
       else
         unloaded = true
         control.prnt_err("The current activity in use cannot be reloaded")
       end     
      when "lfiles"
        framework.modules.reload("lfiles")
      when "rurls"
        framework.modules.reload("rurls")
      when "modules"
        # Reset everything
        framework.modules.mod_load(WXf::ModWorkingDir)
        web_shut
        arg_back   
      when "all"
        web_shut
        framework.modules.mod_load(WXf::ModWorkingDir)
        framework.modules.reload("lfiles")
        framework.modules.reload("rurls")
        arg_back       
      else
        unloaded = true
        control.prnt_dbg(" The following is a list of accepted reload commands:\n")
          arg_reload_comp(nil, nil).sort.each do |cmd|
          puts("#{cmd}\n")
      end
    end
     
    if unloaded == false
      control.prnt_gen("Reloaded: #{item}")
    end
  end
  
  
  #
  # Tab completion of the reload command
  #
  def arg_reload_comp(str, stra)
    list = []
    if (self.in_focus)
      list = ["lfiles", "rurls", "current", "modules", "all"]
    else
      list = ["lfiles", "rurls", "modules", "all"]
    end
   return list
  end  
    
  #
  #
  #
  def wXflist_call 
      WXf::WXfdb::Core.new(WXFDIR, 1)
  end
  
  
   #
   #
   #
   def exploit_list_by_name(args)
      wXflist_call.db.get_exploit_by_name(args)
   end
   
  
    
    ### I'd like to move this over to the module factory/loader as a way to organize our payloads, exploits
    ### Just ref the method created under that class and return the result. Servers dual purposes.
    
    def counter(arg)
      count = 0
     case arg
     when "exploits"     
      list = framework.modules.counter('file_exploit')    
     when "auxiliary"
       list = framework.modules.counter('auxiliary')
     when "buby"
       list = framework.modules.counter('buby')   
     end 
      return list 
    rescue
    end
   
    
  #
  # Shows available exploits in the database
  #
  def show_exploits
    opts = []
    file_list =  list = framework.modules.mod_pair['file_exploit'].sort
    # Display the commands
      tbl = WXf::WXfui::Console::Prints::PrintTable.new(
        'Title'  => "Exploits",
        'Justify'  => 4,             
        'Columns' => 
        [
          'Name',
          'Description'
        ])
            
     file_list.each do |item, obj|
       name =  "file_exploit/#{item}"
       desc =  obj.description.to_s.lstrip.rstrip
       tbl.add_ritems([name,desc[0..50]])
     end       
    tbl.prnt       
   end
  
    
    
  #
  # Show auxiliary mods
  #    
  def show_auxiliary
   list = framework.modules.mod_pair['auxiliary'].sort
   # Display the commands
   tbl = WXf::WXfui::Console::Prints::PrintTable.new(
     'Title'  => "Auxiliary",
     'Justify'  => 4,
     'Columns' =>
       [
         'Name',
         'Description'
       ])
                    
     list.each {|item, obj|
       name =  "auxiliary/#{item}"
       desc =  obj.description.to_s.lstrip.rstrip
       tbl.add_ritems([name,desc[0..50]])
     }
   tbl.prnt
  end
  
  
  #
  # show content
  #
  def show_content
    list = WXf::CONTENT_TYPES.sort_by {|k,v| k.to_i}
    tbl = WXf::WXfui::Console::Prints::PrintTable.new(
      'Title'  => "Content-Types",
      'Justify'  => 4,            
      'Columns' => 
      [
        'Id',
        'Content-Type'
      ])
      
        list.each {|id, name|
          tbl.add_ritems([id,name])
        }
    tbl.prnt
  end  
  
  
  #
  # Show lfiles
  #
  def show_lfiles
       list = framework.modules.lfile_load_list.sort
       # Display the commands
       tbl = WXf::WXfui::Console::Prints::PrintTable.new(
         'Title'  => "Local Files",
         'Justify'  => 4,             
         'Columns' => 
           [
             'Name',
            ])
        list.each {|name, path|
          tbl.add_ritems([name]) 
         }
       tbl.prnt
  end
  
  
  #
  #
  #
  def show_rurls
    list = framework.modules.rurls_load_list.sort
         # Display the commands
         tbl = WXf::WXfui::Console::Prints::PrintTable.new(
           'Title'  => "Rurl(s) Files",
           'Justify'  => 4,             
           'Columns' => 
             [
               'Name',
              ])
     list.each {|name, path|
        tbl.add_ritems([name]) 
      }
    tbl.prnt
  end

  
  #
  # Show a list of user-agents
  #
  def show_ua
  list = WXf::UA_MAP.sort_by {|k,v| k.to_i}
  # Display the commands
    tbl = WXf::WXfui::Console::Prints::PrintTable.new(
      'Title'  => "User-Agents",
      'Justify'  => 4,             
      'Columns' => 
        [
          'Id',
          'User-Agent'
        ])
                          
     list.each {|id, name|
       tbl.add_ritems([id,name]) 
     }
   tbl.prnt
  end  
  
  
  
  def avail_args
    {
        "?"        => "Help menu",
        "back"     => "Move back from the current context",
        "burp"     => "Interface for dealing interacting with Burp",
        "display"  => "Displays the banner artwork to a user",
        "cd"       => "Change Directory",
        "current"  => "Displays the current activity of focus within the stack",
        "ex"       => "Exit the console (shortcut)",
        "exit"     => "Exit the console",
        "help"     => "Help menu",
        "import"   => "Imports a user provided file",
        "info"     => "Displays info about one or more module",
        "reload"   => "Reload rurls and lfiles lists",
        "server"   => "Setup a local webserver",
        "set"      => "Sets a variable to a value",
        "show"     => "Displays modules of a given type",
        "update"   => "Upates the framework",
        "use"      => "Selects an exploit by name",
        "version"  => "Show the framework and console library version numbers",
     }
  end
  
  
end

end end end end