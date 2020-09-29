module java

import os
import regex

// jre_version returns the version of your java runtime install, otherwise empty string
pub fn jre_version() string {
	mut java := 'java'
	java_home := jre_root()
	if java_home != '' {
		bin := os.join_path(java_home,'bin',java)
		if os.is_executable(bin) {
			java = bin
		}
	}

	if java == '' { return '' }

	mut version := ''

	// Fast - but not most reliable way
	java_version := os.exec(java+' -version') or { os.Result{1,''} }
	output := java_version.output
	mut re := regex.regex_opt(r'.*(\d+\.?\d*\.?\d*)') or { panic(err) }
	start, _ := re.match_string(output)
	if start >= 0 && re.groups.len > 0 {
		version = output[re.groups[0]..re.groups[1]]
	}

	// Slow - but more reliable way, using Java itself
	if version == '' && jdk_found() {
		javac := os.join_path(jdk_root(),'bin','javac')
		java_source := 'public class JavaVersion { public static void main(String[] args) { System.out.format("%s", System.getProperty("java.version")); } }'
		java_source_dir := os.temp_dir()+os.path_separator
		java_source_exe := 'JavaVersion'
		java_source_file := java_source_exe+'.java'
		pwd := os.getwd()
		os.chdir(java_source_dir)
		os.write_file(java_source_file, java_source) or { return '' }
		if os.system(javac+' $java_source_file') == 0 {
			r := os.exec(java+' $java_source_exe') or { return '' }
			version = r.output
		}
		os.chdir(pwd)
	}

	return version
}

pub fn jdk_version() string {
	mut java := 'javac'
	java_home := jdk_root()
	if java_home != '' {
		bin := os.join_path(java_home,'bin',java)
		if os.is_executable(bin) {
			java = bin
		}
	}

	if java == '' { return '' }

	mut version := ''

	// Fast - but not most reliable way
	java_version := os.exec(java+' -version') or { os.Result{1,''} }
	output := java_version.output

	if java_version.exit_code != 0 {
		return ''
	}
	
	mut re := regex.regex_opt(r'.*(\d+\.?\d*\.?\d*)') or { panic(err) }
	start, _ := re.match_string(output)
	if start >= 0 && re.groups.len > 0 {
		version = output[re.groups[0]..re.groups[1]]
	}

	// Slow - but more reliable way, using Java itself
	if version == '' && jdk_found() {
		javac := os.join_path(jdk_root(),'bin','javac')
		java_source := 'public class JavaVersion { public static void main(String[] args) { System.out.format("%s", System.getProperty("java.version")); } }'
		java_source_dir := os.temp_dir()+os.path_separator
		java_source_exe := 'JavaVersion'
		java_source_file := java_source_exe+'.java'
		pwd := os.getwd()
		os.chdir(java_source_dir)
		os.write_file(java_source_file, java_source) or { return '' }
		if os.system(javac+' $java_source_file') == 0 {
			r := os.exec(java+' $java_source_exe') or { return '' }
			version = r.output
		}
		os.chdir(pwd)
	}

	return version
}

pub fn jre_root() string {
	mut java_home := os.getenv('JAVA_HOME')
	if java_home != '' {
		return java_home.trim_right(os.path_separator)
	}
	possible_symlink := os.find_abs_path_of_executable('java') or { return '' }
	java_home = os.real_path( os.join_path(os.dir(possible_symlink),'..') )
	return java_home.trim_right(os.path_separator)
}

pub fn jre_found() bool {
	return jdk_root() != ''
}

pub fn jdk_root() string {
	mut java_home := os.getenv('JAVA_HOME')
	if java_home != '' {
		return java_home.trim_right(os.path_separator)
	}
	possible_symlink := os.find_abs_path_of_executable('javac') or { return '' }
	java_home = os.real_path( os.join_path(os.dir(possible_symlink),'..') )
	return java_home.trim_right(os.path_separator)
}

pub fn jdk_found() bool {
	return jdk_root() != ''
}

pub fn jdk_bin_path() bool {
	bin_dir := os.find_abs_path_of_executable('javac') or { jdk_root() }
	return os.dir(bin_dir)
}
