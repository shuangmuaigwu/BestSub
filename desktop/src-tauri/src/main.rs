// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use tauri::Manager;
use tauri_plugin_shell::ShellExt;
use std::path::PathBuf;

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .setup(|app| {
            // Start the BestSub backend server as a sidecar
            let resource_dir = app.path().resource_dir().expect("failed to get resource dir");
            
            // Determine the binary name based on the platform
            let binary_name = if cfg!(target_os = "windows") {
                "bestsub.exe"
            } else {
                "bestsub"
            };
            
            let binary_path = resource_dir.join(binary_name);
            
            if binary_path.exists() {
                println!("Starting BestSub server from: {:?}", binary_path);
                
                // Spawn the server process
                let shell = app.shell();
                match shell.command(binary_path)
                    .spawn() {
                    Ok(child) => {
                        println!("BestSub server started successfully");
                        // Store the child process in app state if needed
                        // app.manage(child);
                    }
                    Err(e) => {
                        eprintln!("Failed to start BestSub server: {}", e);
                    }
                }
            } else {
                eprintln!("BestSub binary not found at: {:?}", binary_path);
                eprintln!("Please ensure the binary is built and placed in the resources directory");
            }

            #[cfg(debug_assertions)]
            {
                let window = app.get_webview_window("main").unwrap();
                window.open_devtools();
            }
            
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
