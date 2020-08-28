from collections import Counter


def get_actor_primary_role(actor_id, actorlinks_by_actor_id):
    this_actor_links = actorlinks_by_actor_id[actor_id]
    all_roles = []
    for actorlink in this_actor_links:
        link_roles = actorlink['actor_roles_all'].split("; ")
        all_roles.extend(link_roles)
    counts = Counter(all_roles)
    most_common_role = counts.most_common(1)[0][0]
    # if most common role is "unknown" and there are other roles, pick the
    # second most common
    if most_common_role == "unknown" and len(counts) > 1:
        most_common_role = counts.most_common(2)[1][0]
    return most_common_role
