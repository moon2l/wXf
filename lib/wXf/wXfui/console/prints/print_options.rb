module WXf
module WXfui
module Console
module Prints


class PrintOptions
  
  def initialize(output, framework)
    @output = output
    @framework = framework
  end

  #
  # Shows available exploits in the database
  #
  def show_exploits
    exploits = @framework.modules.mod_pair['exploit'].sort
    # Display the commands
      tbl = WXf::WXfui::Console::Prints::PrintTable.new(
        'Output' => @output,
        'Title'  => "Exploits",
        'Justify'  => 4,             
        'Columns' => 
        [
          'Name',
          'Description'
        ])
        
     exploits.each do |item, obj|
      name =  "exploit/#{item}"
      desc =  obj.description.to_s.lstrip.rstrip
      tbl.add_ritems([name, desc[0..50]])
     end
    tbl.prnt       
   end
 
   
  #
  # Show payload mods
  #    
  def show_payloads
   list = @framework.modules.mod_pair['payload'].sort
   # Display the commands
   tbl = WXf::WXfui::Console::Prints::PrintTable.new(
     'Output' => @output,
     'Title'  => "Payloads",
     'Justify'  => 4,
     'Columns' =>
       [
         'Name',
         'Description'
       ])
                    
     list.each {|item, obj|
       name =  "payload/#{item}"
       desc =  obj.description.to_s.lstrip.rstrip
       tbl.add_ritems([name,desc[0..50]])
     }
   tbl.prnt
  end
  
    
  #
  # Show auxiliary mods
  #    
  def show_auxiliary
   list = @framework.modules.mod_pair['auxiliary'].sort
   # Display the commands
   tbl = WXf::WXfui::Console::Prints::PrintTable.new(
     'Output' => @output,
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
      'Output' => @output,
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
       list = @framework.modules.lfile_load_list.sort
       # Display the commands
       tbl = WXf::WXfui::Console::Prints::PrintTable.new(
         'Output' => @output,
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
    list = @framework.modules.rurls_load_list.sort
         # Display the commands
         tbl = WXf::WXfui::Console::Prints::PrintTable.new(
           'Output' => @output,
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
      'Output' => @output,
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
  
    # 
    # When an in_focus exists this method becomes the de-facto to module specific options
    #
    def show_options(activity)      
     if activity.type.match(/(exploit|auxiliary)/)      
       # Display the commands
           tbl = WXf::WXfui::Console::Prints::PrintTable.new(
           'Output' => @output,
           'Title' => "Module Options:",
           'Justify'  => 4,
           'Columns' =>
           [
             'Name',
             'Current Setting',
             'Required',
             'Description',
                                      
           ])
                   
           activity.options.sarr.each { |item|
           name, option = item
           val = activity.datahash[name]
           tbl.add_ritems([name,val, "#{option.required}", option.desc]) 
           }
           tbl.prnt        
        
     elsif activity.type.match(/(webserver|xmlrpc)/)
      activity.usage    
     end
     
      if activity.respond_to?('payload') and ! activity.payload.nil?
       if activity.payload.type.match(/payload/)      
       # Display the commands
           tbl = WXf::WXfui::Console::Prints::PrintTable.new(
           'Output' => @output,
           'Title' => "Payload Options:",
           'Justify'  => 4,
           'Columns' =>
           [
             'Name',
             'Current Setting',
             'Required',
             'Description',
                                      
           ])
                   
           activity.payload.options.sarr.each { |item|
           name, option = item
           val = activity.payload.datahash[name] 
           tbl.add_ritems([name,val, "#{option.required}", option.desc]) 
           }
           tbl.prnt        
          
          end  
       end 
    end
    
    
   #
   # Show Remote File Inclusions Strings
   #
   def show_rfi
     list = WXFDB.get_rfi_list.sort
      # Display the commands
        tbl = WXf::WXfui::Console::Prints::PrintTable.new(
          'Output' => @output,
          'Title'  => "RFI List",
          'Justify'  => 4,             
          'Columns' => 
            [
              'Name',
              'Description',
              'Platform',
              'Language'
            ])
                              
         list.each {|name, desc, platform, lang|
           tbl.add_ritems([name,desc, platform, lang]) 
         }
       tbl.prnt     
   end 
  
end

end end end end