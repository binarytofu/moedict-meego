# -*- coding: utf-8 -*-
import json
import codecs
import re

def loadJson(path):
	stream = codecs.open(path, encoding='utf-8', mode='r')
	return json.load(stream)

source = loadJson('dict-revised.unicode.json')

# TODO: Split main dictionary and indices into different files
index = {}
lookupTable = {'zhuyin': {}, 'pinyin': {}}
abbrTable = loadJson('abbreviation.json')
ignoreExpr = [re.compile(x) for x in [r'\{\[[0-9a-f]{4}\]\}', u'\uDB40[\uDD00-\uDD0F]', u'[⿰⿸⿹⿻]']]

def ignoreEntry(title):
	for expr in ignoreExpr:
		if expr.search(title): return True
	return False

def addEntry(source, category, value):
	if not source: return
	if not source in lookupTable[category]:
		lookupTable[category][source] = []
	lookupTable[category][source].append(value)
	
for entry in source:
	title = entry['title']
	if ignoreEntry(title): continue

	for h in entry['heteronyms']:
		if 'bopomofo' in h: addEntry(h['bopomofo'], 'zhuyin', title)
		if 'pinyin' in h: addEntry(h['pinyin'], 'pinyin', title)
		# More index entries can be added here

	raw_data = json.dumps(entry, ensure_ascii=False, separators=(',',':'))
	for long_name in abbrTable:
		raw_data = raw_data.replace('"%s"' % long_name, '"%s"' % abbrTable[long_name])
	raw_data = raw_data.replace("'", "\'")	# Escape any single quote
	raw_data = raw_data.replace('"', "'")	# Use single quote instead of double quote
	index[title] = raw_data

def dumpJson(obj, path, indent=None):
	stream = codecs.open(path, encoding='utf-8', mode='w+')
	json.dump(obj, stream, ensure_ascii=False, indent=indent, separators=(',',':'), sort_keys=True)

dumpJson(index, '../data/index.json', 0)
dumpJson(lookupTable, '../data/lookuptable.json')
