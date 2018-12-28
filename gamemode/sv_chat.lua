concommand.Add("pm", function(ply, cmd, args)

  if not args[1] or not args[2] then 
    ply:ChatPrint("Usage: /pm name message") 
    return 
  end
  local name = string.lower(args[1])
  table.remove(args, 1)
  local recvr
  local num = 0
  for i, v in pairs(player.GetAll()) do 
    if string.find(string.lower(v:Name()), name, 1, true) then
      recvr = v
      num = num + 1
    end
  end
  if num > 1 then 
    ply:ChatPrint("Too many names contain "..name) 
    return 
  end
  if not recvr then
    ply:ChatPrint("Player not found")
    return 
  end
  
  recvr.LastPM = ply
  SendChatText( ply, Color(236, 213, 45), ply:Nick().." [PM ("..recvr:Name()..")]: "..table.concat(args, " ") )
  SendChatText( recvr, Color(236, 213, 45), ply:Nick().." [PM]: "..table.concat(args, " "))

end)


concommand.Add("reply", function(ply, cmd, args)
  if not args[1] then 
    ply:ChatPrint("Usage: /reply message") 
    return 
  end
  if not ply.LastPM then
    ply:ChatPrint("You have not received a PM", "NOTIFY_ERROR", 4)
    return "" 
  end
  local recvr = ply.LastPM
  if not recvr:IsValid() then 
    ply:ChatPrint("The player you are replying to has left", "NOTIFY_ERROR", 4)
    return "" 
  end
  recvr.LastPM = ply
  
  if not recvr then return "" end
  
  SendChatText( ply, Color(236, 213, 45), ply:Nick().." [PM ("..recvr:Name()..")]: "..table.concat(args, " ") )
  
  SendChatText( recvr, Color(236, 213, 45), ply:Nick().." [PM]: "..table.concat(args, " "))
  
end)


concommand.Add("superchat", function(ply, cmd, args)
  if not args[1] then 
    ply:ChatPrint("Usage: /s message") 
    return 
  end
  if not ply:IsSuperAdmin() then 
    ply:ChatPrint("You are not a super admin!", "NOTIFY_ERROR", 5) 
    return 
  end
  for k, v in pairs(player.GetAll()) do
    if v:IsSuperAdmin() then
	
	SendChatText( v, Color(95, 236, 47), ply:Nick().." [SUPER]: "..table.concat(args, " "))
	
    end
  end
end)

concommand.Add("adminchat", function(ply, cmd, args)
  if not args[1] then 
    ply:ChatPrint("Usage: /a message") 
    return 
  end
  if not ply:IsAdmin() then 
    ply:ChatPrint("You are not a super admin!", "NOTIFY_ERROR", 5) 
    return 
  end
  for k, v in pairs(player.GetAll()) do
    if v:IsAdmin() then
	
	SendChatText( v, Color(128, 128, 255), ply:Nick().." [ADMIN]: "..table.concat(args, " "))
	
    end
  end
end)

concommand.Add("modchat", function(ply, cmd, args)
  if not args[1] then 
    ply:ChatPrint("Usage: /m message") 
    return 
  end
  if not ply:IsUserGroup("moderator") and not ply:IsAdmin() and not ply:IsSuperAdmin() then 
    ply:ChatPrint("You are not a moderator!", "NOTIFY_ERROR", 5) 
    return 
  end
  for k, v in pairs(player.GetAll()) do
    if v:IsUserGroup("moderator") or v:IsAdmin() then
	
	SendChatText( v, Color(255, 128, 255), ply:Nick().." [MOD]: "..table.concat(args, " "))
	
    end
  end
end)
