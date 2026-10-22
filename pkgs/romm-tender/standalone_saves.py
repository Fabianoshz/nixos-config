"""Saves that Tender's resolver (atlas) cannot see, configured per system in
standalone_saves.json:

* {dir, ext, serverExt?} -- one <rom stem><ext> in dir (standalone melonDS).
  serverExt is the name used on RomM, so a RetroArch core of the same system
  shares it (melonDS DS writes .srm).
* {dir, stage, layout} -- a folder per game (PPSSPP SAVEDATA, Azahar title
  data). Tender syncs it as <rom stem>.zip in stage; the zip is rebuilt from
  the emulator's folder before every sync and unpacked into it after a
  download.
"""

import json
import logging
import os
import re
import shutil
import struct
import time
import zipfile

_log = logging.getLogger("standalone_saves")

with open(os.path.join(os.path.dirname(__file__), "standalone_saves.json")) as f:
    _TABLE = json.load(f)

_ZIP_TIME = (1980, 1, 1, 0, 0, 0)


def _stem(path):
    return os.path.splitext(os.path.basename(path))[0]


def _is_folder(entry):
    return "layout" in entry


# --- Hooks called from Tender -------------------------------------------------


def saves_dir(system, file_path):
    entry = _TABLE.get(system)
    if entry is None:
        return None
    if not _is_folder(entry):
        return entry["dir"]
    try:
        _pack(entry, file_path)
    except Exception:
        _log.exception("packing %s save for %s failed", system, file_path)
    return entry["stage"]


def save_answer(system, content_path, installed):
    entry = _TABLE.get(system)
    if entry is None:
        return None
    from domain.save_answer import build_save_answer

    folder = _is_folder(entry)
    return build_save_answer(
        emulator=entry["emulator"],
        directory=entry["stage"] if folder else entry["dir"],
        backing_directory=None,
        granularity="per-game-file",
        needs=(),
        file_set_state="declared",
        files=(_stem(content_path) + (".zip" if folder else entry["ext"]),),
        groups=(),
        caveats=(),
        content_installed=installed,
    )


def emulator_tag(system):
    entry = _TABLE.get(system)
    return entry["emulator"] if entry else None


def server_to_local_name(known_names, computed):
    stem, ext = os.path.splitext(computed)
    for entry in _TABLE.values():
        if entry.get("serverExt") == ext and stem + entry["ext"] in known_names:
            return stem + entry["ext"]
    return computed


def upload_name(file_path):
    name = os.path.basename(file_path)
    for entry in _TABLE.values():
        if entry.get("serverExt") and os.path.dirname(file_path) == entry["dir"] and name.endswith(entry["ext"]):
            return name[: -len(entry["ext"])] + entry["serverExt"]
    return name


def after_download(local_path):
    for entry in _TABLE.values():
        if _is_folder(entry) and os.path.dirname(local_path) == entry["stage"] and local_path.endswith(".zip"):
            try:
                _unpack(entry, local_path)
            except Exception:
                _log.exception("unpacking %s failed", local_path)
            return


# --- Folder saves ---------------------------------------------------------------


def _state_path(entry):
    return os.path.join(entry["stage"], "state.json")


def _state(entry):
    try:
        with open(_state_path(entry)) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def _save_state(entry, state):
    os.makedirs(entry["stage"], exist_ok=True)
    tmp = _state_path(entry) + ".tmp"
    with open(tmp, "w") as f:
        json.dump(state, f, indent=1, sort_keys=True)
    os.replace(tmp, _state_path(entry))


def _read_tree(root):
    files = {}
    for dirpath, _dirs, names in os.walk(root):
        for name in names:
            path = os.path.join(dirpath, name)
            with open(path, "rb") as f:
                files[os.path.relpath(path, root)] = f.read()
    return files


def _zip_bytes(files):
    import io

    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
        for name in sorted(files):
            z.writestr(zipfile.ZipInfo(name, _ZIP_TIME), files[name])
    return buf.getvalue()


def _pack(entry, rom_path):
    stem = _stem(rom_path)
    files = _LAYOUTS[entry["layout"]][0](entry, rom_path)
    if not files:
        return
    data = _zip_bytes(files)
    zip_path = os.path.join(entry["stage"], stem + ".zip")
    try:
        with open(zip_path, "rb") as f:
            if f.read() == data:
                return
    except OSError:
        pass
    os.makedirs(entry["stage"], exist_ok=True)
    with open(zip_path + ".pack", "wb") as f:
        f.write(data)
    os.replace(zip_path + ".pack", zip_path)
    _log.info("packed %d save files into %s", len(files), zip_path)


def _unpack(entry, zip_path):
    stem = _stem(zip_path)
    with zipfile.ZipFile(zip_path) as z:
        files = {i.filename: z.read(i) for i in z.infolist() if not i.is_dir()}
    targets = _LAYOUTS[entry["layout"]][1](entry, stem, files)
    backup = os.path.join(entry["stage"], ".backup", f"{stem}-{time.strftime('%Y%m%d-%H%M%S')}")
    for target, tree in targets.items():
        if os.path.isdir(target):
            shutil.copytree(target, os.path.join(backup, os.path.basename(target)))
            shutil.rmtree(target)
        for name, data in tree.items():
            path = os.path.join(target, name)
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "wb") as f:
                f.write(data)
        _log.info("unpacked %s into %s", zip_path, target)
    # Re-pack so the stage zip is byte-identical to what the next sync builds.
    with open(zip_path, "wb") as f:
        f.write(_zip_bytes(files))


# PPSSPP: <SAVEDATA>/<GAMEID><suffix>/ per save, PARAM.SFO names the game.
# One folder zips flat (as PPSSPP standalone uploads), several zip by folder.


def _sfo(data):
    _magic, _ver, keys, values, count = struct.unpack_from("<4sIIII", data, 0)
    out = {}
    for i in range(count):
        key_off, fmt, length, _max, val_off = struct.unpack_from("<HHIII", data, 20 + i * 16)
        key = data[keys + key_off : data.index(b"\0", keys + key_off)].decode()
        value = data[values + val_off : values + val_off + length]
        out[key] = struct.unpack_from("<I", value)[0] if fmt == 0x0404 else value.rstrip(b"\0").decode("utf-8", "replace")
    return out


def _norm_title(name):
    name = re.sub(r"\([^)]*\)|\[[^]]*\]", "", name)
    return re.sub(r"[^a-z0-9]", "", name.lower())


def _psp_folders(entry, rom_path):
    root = entry["dir"]
    if not os.path.isdir(root):
        return []
    ids = set(_state(entry).get(_stem(rom_path), {}).get("ids", []))
    want = _norm_title(_stem(rom_path))
    found = []
    for name in sorted(os.listdir(root)):
        sfo = os.path.join(root, name, "PARAM.SFO")
        if not os.path.isfile(sfo):
            continue
        with open(sfo, "rb") as f:
            title = _sfo(f.read()).get("TITLE", "")
        if name[:9] in ids or (title and _norm_title(title) == want):
            found.append(name)
    return found


def _psp_pack(entry, rom_path):
    folders = _psp_folders(entry, rom_path)
    if len(folders) == 1:
        return _read_tree(os.path.join(entry["dir"], folders[0]))
    files = {}
    for name in folders:
        for rel, data in _read_tree(os.path.join(entry["dir"], name)).items():
            files[f"{name}/{rel}"] = data
    return files


def _psp_unpack(entry, stem, files):
    if "PARAM.SFO" in files:
        folders = {_sfo(files["PARAM.SFO"])["SAVEDATA_DIRECTORY"]: files}
    else:
        folders = {}
        for name, data in files.items():
            top, _, rel = name.partition("/")
            folders.setdefault(top, {})[rel] = data
    state = _state(entry)
    ids = set(state.get(stem, {}).get("ids", []))
    ids.update(name[:9] for name in folders)
    state.setdefault(stem, {})["ids"] = sorted(ids)
    _save_state(entry, state)
    return {os.path.join(entry["dir"], name): tree for name, tree in folders.items()}


# Azahar: <sdmc title dir>/<high>/<low>/data/, title ID from the ROM header.


def _title_id(rom_path):
    with open(rom_path, "rb") as f:
        head = f.read(4096)
    if head[:4] == b"Z3DS":
        i = head.find(b"titleinfo\0")
        if i >= 0:
            return struct.unpack_from("<Q", head, i + 9)[0]
    if head[0x100:0x104] == b"NCSD":
        return struct.unpack_from("<Q", head, 0x108)[0]
    return None


def _n3ds_data_dir(entry, rom_path):
    tid = _title_id(rom_path)
    if tid is None:
        return None
    return os.path.join(entry["dir"], f"{tid >> 32:08x}", f"{tid & 0xFFFFFFFF:08x}", "data")


def _n3ds_pack(entry, rom_path):
    data_dir = _n3ds_data_dir(entry, rom_path)
    if data_dir is None:
        return {}
    state = _state(entry)
    if state.get(_stem(rom_path), {}).get("target") != data_dir:
        state.setdefault(_stem(rom_path), {})["target"] = data_dir
        _save_state(entry, state)
    files = _read_tree(data_dir) if os.path.isdir(data_dir) else {}
    # Azahar creates the archive on first boot; only real save files count.
    return files if any(os.sep in name for name in files) else {}


def _n3ds_unpack(entry, stem, files):
    target = _state(entry).get(stem, {}).get("target")
    if target is None:
        raise RuntimeError(f"no Azahar title folder known for {stem}")
    return {target: files}


_LAYOUTS = {
    "psp-savedata": (_psp_pack, _psp_unpack),
    "3ds-title": (_n3ds_pack, _n3ds_unpack),
}
