//
//  pokem0nBridging.h
//  pokem0nLoader
//
//  Created by Lakhan Lothiyi on 12/11/2022.
//

#ifndef pokem0nBridging_h
#define pokem0nBridging_h
#include <spawn.h>

#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE 1
int posix_spawnattr_set_persona_np(const posix_spawnattr_t* __restrict, uid_t, uint32_t);
int posix_spawnattr_set_persona_uid_np(const posix_spawnattr_t* __restrict, uid_t);
int posix_spawnattr_set_persona_gid_np(const posix_spawnattr_t* __restrict, uid_t);

#endif /* pokem0nBridging_h */
